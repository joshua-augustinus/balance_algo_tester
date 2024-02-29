defmodule Teiserver.Battle.Balance.SplitOneChevs do
  alias Teiserver.CacheUser
  alias Teiserver.Battle.BalanceLib

    @doc """
  Input:
  expanded_group:
  [
      %{count: 2, members: [1, 4], group_rating: 13, ratings: [8, 5]},
      %{count: 1, members: [2], group_rating: 6, ratings: [6]},
      %{count: 1, members: [3], group_rating: 7, ratings: [7]}
  ]
  """
  def perform(expanded_group, team_count) do
    members = flatten_members(expanded_group)
    teams = assign_teams(members, team_count)
    standardise_result(teams)
  end

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

    @doc """
  raw_input=
     [
             %{
               members: [
                 %{rating: 17, rank: 0, member_id: 3},
                 %{rating: 8, rank: 4, member_id: 100}
               ],
               team_id: 1
             },
             %{
               members: [
                 %{rating: 6, rank: 0, member_id: 2},
                 %{rating: 5, rank: 0, member_id: 4}
               ],
               team_id: 2
             }
           ]
  """
  def standardise_result(raw_input) do
    ratings = standardise_ratings(raw_input)
    team_sizes=standardise_team_sizes(raw_input)
    team_groups= standardise_team_groups(raw_input)
    means =
      ratings
      |> Map.new(fn {team, rating_sum} ->
        {team, rating_sum / max(team_sizes[team], 1)}
      end)

      stdevs =
        team_groups
        |> Map.new(fn {team, group} ->
          stdev =
            group
            |> Enum.map(fn m -> m.ratings end)
            |> List.flatten()
            |> Statistics.stdev()

          {team, stdev}
        end)
    %{
      team_groups: team_groups,
      team_players: standardise_team_players(raw_input),
      ratings: ratings,
      captains: standardise_captains(raw_input),
      team_sizes: team_sizes,
      deviation: BalanceLib.get_deviation(ratings),
      means: means,
      stdevs: stdevs
    }
  end


  def standardise_team_groups(raw_input) do
    Map.new(raw_input, fn x-> {x.team_id, standardise_members(x.members)}end)
  end

  @doc """
  members=
  [
                 %{rating: 6, rank: 0, member_id: 2},
                 %{rating: 5, rank: 0, member_id: 4}
               ]
  output= [
                 %{members: [2], count: 1, group_rating: 6, ratings: [6]},
                 %{members: [4], count: 1, group_rating: 5, ratings: [5]}
               ]
  """
  def standardise_members(members) do
    for  %{rating: rating,   member_id: member_id } <- members,
      do: %{members: [member_id], count: 1, group_rating: rating, ratings: [rating]}
  end

  def standardise_team_players(raw_input) do
    Map.new(raw_input, fn x-> {x.team_id, standardise_member_ids(x.members)}end)

  end

  def standardise_member_ids(members) do
    for  %{  member_id: member_id } <- members,
      do: member_id
  end

  def standardise_ratings(raw_input) do
    Map.new(raw_input, fn x-> {x.team_id, sum_ratings(x.members)}end)
  end

  @doc """
  members = [
                 %{rating: 17, rank: 0, member_id: 3},
                 %{rating: 8, rank: 4, member_id: 100}
            ]
               """
  def sum_ratings(members) do
    Enum.reduce(members, 0,fn x,acc->
      x.rating + acc
    end)
  end

  def standardise_captains(raw_input) do
    Map.new(raw_input, fn x-> {x.team_id, get_captain(x.members).member_id}end)

  end

  def get_captain(members) do
    default_captain = Enum.at(members,0)
    Enum.reduce(members, default_captain ,fn x,acc->
      if(x.rating > acc.rating) do
        x
    else
      acc
    end

    end)
  end

  def standardise_team_sizes(raw_input) do
    Map.new(raw_input, fn x-> {x.team_id, length(x.members)}end)

  end

end
