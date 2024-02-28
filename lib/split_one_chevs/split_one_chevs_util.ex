defmodule Teiserver.Battle.Balance.SplitOneChevs.SplitOneChevsUtil do
  alias Teiserver.CacheUser

  @doc """
  Input:
  expanded_group:
  [
      %{count: 2, members: [1, 4], group_rating: 13, ratings: [8, 5]},
      %{count: 1, members: [2], group_rating: 6, ratings: [6]},
      %{count: 1, members: [3], group_rating: 7, ratings: [7]}
  ]

  Output:  [
  %{rating: 8, member_id: 1},
  %{rating: 5, member_id: 4},
  %{rating: 6, member_id: 2},
  %{rating: 7, member_id: 3}
  ]
  """
  def flatten_members(expanded_group) do
    for %{members: members, ratings: ratings} <- expanded_group,
        # Zipping will create binary tuples from 2 lists
        {id, rating} <- Enum.zip(members, ratings),
        # Create result value
        rank = get_rank(id),
        do: %{member_id: id, rating: rating, rank: rank}
  end

  def get_rank(member_id) do
    CacheUser.calculate_rank(member_id, "Playtime")
  end
end
