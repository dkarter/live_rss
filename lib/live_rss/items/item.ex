defmodule LiveRSS.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiveRSS.Feeds.Feed

  @required_attributes [
    :description,
    :guid,
    :link,
    :title,
    :pub_date,
    :feed_id
  ]

  @allowed_attributes @required_attributes ++
                        [
                          :categories,
                          :is_read
                        ]

  schema "items" do
    field :categories, {:array, :string}
    field :description, :string
    field :guid, :string
    field :is_read, :boolean
    field :link, :string
    field :pub_date, :naive_datetime
    field :title, :string

    belongs_to :feed, Feed

    timestamps()
  end

  @doc false
  def changeset(item \\ %__MODULE__{}, attrs) do
    item
    |> cast(attrs, @allowed_attributes)
    |> validate_required(@required_attributes)
    |> assoc_constraint(:feed)
  end
end
