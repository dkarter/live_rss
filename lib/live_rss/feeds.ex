defmodule LiveRSS.Feeds do
  alias Ecto.Changeset

  alias LiveRSS.Feeds.Feed
  alias LiveRSS.Repo

  @spec create_feed(map()) :: {:ok, Feed.t()} | {:error, Changeset.t()}
  def create_feed(attrs) do
    attrs
    |> Feed.changeset()
    |> Repo.insert()
  end

  @spec delete_feed(binary() | number()) :: {:ok, Feed.t()} | {:error, Changeset.t()}
  def delete_feed(id) do
    Feed
    |> Repo.get(id)
    |> Repo.delete()
  end

  @spec list_feeds() :: [Feed.t()]
  def list_feeds do
    Repo.all(Feed)
  end
end
