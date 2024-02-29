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

  @doc """
  member_list: A sorted list of members e.g.
  [
  %{rating: 8, member_id: 1},
  %{rating: 5, member_id: 4},
  %{rating: 6, member_id: 2},
  %{rating: 7, member_id: 3}
  ]
  """
  def assign_teams(member_list, number_of_teams) do
    Enum.reduce(member_list, create_empty_teams(number_of_teams), fn x, acc ->
      picking_team = get_picking_team(acc)
      update_picking_team = Map.merge(picking_team, %{members: [x | picking_team.members]})
      [update_picking_team | get_non_picking_teams(acc, picking_team)]
    end)
  end

  @spec create_empty_teams(any()) :: any()
  def create_empty_teams(count) do
    for i <- 1..count,
        do: %{team_id: i, members: []}
  end

  @spec get_picking_team(any()) :: any()
  def get_picking_team(teams) do
    default_picking_team = Enum.at(teams, 0)

    Enum.reduce(teams, default_picking_team, fn x, acc ->
      # Team is picker if it has least members
      if(length(x.members) < length(acc.members)) do
        x
      else
        # Team is picker if it is tied for least and has lower team rating
        if(
          length(x.members) == length(acc.members) && get_team_rating(x) < get_team_rating(acc)
        ) do
          x
        else
          acc
        end
      end
    end)
  end

  def get_non_picking_teams(teams, picking_team) do
    Enum.filter(teams, fn x -> x.team_id != picking_team.team_id end)
  end

  def get_team_rating(team) do
    Enum.reduce(team.members, 0, fn x, acc ->
      acc + x.rating
    end)
  end
end
