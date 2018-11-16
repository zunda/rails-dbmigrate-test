class DropTextFromArticles < ActiveRecord::Migration[5.2]
  def up
    execute <<_REMOVE_TRIGGER
DROP TRIGGER sync_to_body_trigger ON articles;
DROP FUNCTION sync_to_body();
_REMOVE_TRIGGER
    remove_column :articles, :text
  end

  def down
    add_column :articles, :text, :text
    execute <<_ADD_TRIGGER
CREATE OR REPLACE FUNCTION sync_to_body()
  RETURNS TRIGGER AS $$
  BEGIN
    IF NEW.body IS NULL THEN
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
end
