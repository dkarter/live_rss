defmodule LiveRSS.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :categories, {:array, :string}
      add :description, :string, null: false
      add :feed_id, references(:feeds, on_delete: :nothing), null: false
      add :guid, :string, null: false
      add :is_read, :boolean, null: false, default: false
      add :link, :string, null: false
      add :pub_date, :naive_datetime, null: false
      add :title, :string, null: false

      timestamps()
    end

    create unique_index(:items, [:feed_id, :guid])
    create index(:items, [:categories])
    create index(:items, [:description])
    create index(:items, [:feed_id])
    create index(:items, [:guid])
    create index(:items, [:is_read])
    create index(:items, [:pub_date])
    create index(:items, [:title])
  end
end
