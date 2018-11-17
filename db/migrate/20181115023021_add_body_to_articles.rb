class AddBodyToArticles < ActiveRecord::Migration[5.2]
  def up
    add_column :articles, :body, :text
    execute <<_ADD_TRIGGER
UPDATE articles SET body = text;
CREATE OR REPLACE FUNCTION sync_to_body()
  RETURNS TRIGGER AS $$
  BEGIN
    IF ( TG_OP = 'UPDATE' AND NEW.text != OLD.text OR NEW.body IS NULL ) THEN
      NEW.body := NEW.text;
    END IF;
    RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;

CREATE TRIGGER sync_to_body_trigger
  BEFORE INSERT OR UPDATE OF text ON articles
  FOR EACH ROW EXECUTE PROCEDURE sync_to_body();
_ADD_TRIGGER
  end

  def down
    execute <<_REMOVE_TRIGGER
DROP TRIGGER sync_to_body_trigger ON articles;
DROP FUNCTION sync_to_body();
UPDATE articles SET text = body;
_REMOVE_TRIGGER
    remove_column :articles, :body
  end
end
