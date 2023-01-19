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

  @spec delete_feed(number() | binary()) :: {:ok, Feed.t()} | {:error, Changeset.t()}
  def delete_feed(id) do
    id
    |> get_feed()
    |> Repo.delete()
  end

  @spec get_feed(number() | binary()) :: Feed.t() | nil
  def get_feed(id) do
    Feed
    |> Repo.get(id)
  end

  @spec list_feeds() :: [Feed.t()]
  def list_feeds do
    Repo.all(Feed)
  end
end
