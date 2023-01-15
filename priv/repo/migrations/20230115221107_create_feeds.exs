defmodule LiveRSS.Repo.Migrations.CreateFeeds do
  use Ecto.Migration

  def change do
    create table(:feeds) do
      add :name, :string, null: false
      add :url, :string, null: false

      timestamps()
    end
  end
end
