defmodule Teiserver.Battle.SplitOneChevsTest do
  use ExUnit.Case, async: false
  alias Teiserver.Battle.Balance.SplitOneChevs
  alias Teiserver.Battle.Logger
  alias Teiserver.Battle.BalanceLib

  #Define constants
  @split_algo "split_one_chevs"

  test "split one chevs empty" do
    result =
      BalanceLib.create_balance(
        [

        ],
        4,
        algorithm: @split_algo
      )

      assert result ==%{
        logs: [],
        ratings: %{},
        time_taken: 0,
        captains: %{},
        deviation: 0,
        team_groups: %{},
        team_players: %{},
        team_sizes: %{},
        means: %{},
        stdevs: %{}
      }
  end

  test "split one chevs FFA" do
    result =
      BalanceLib.create_balance(
        [
          %{1 => 5},
          %{2 => 6},
          %{3 => 7},
          %{4 => 8}
        ],
        4,
        algorithm: @split_algo
      )

      assert result.team_players == %{1 => [4], 2 => [3], 3 => [2], 4 => [1]}
  end

  test "split one chevs team FFA" do
    result =
      BalanceLib.create_balance(
        [
          %{1 => 5},
          %{2 => 6},
          %{3 => 7},
          %{4 => 8},
          %{5 => 9},
          %{6 => 9}
        ],
        3,
        algorithm: @split_algo
      )

    assert result.team_players == %{1 => [1, 5], 2 => [2, 6], 3 => [3, 4]}
  end

  test "split one chevs simple group" do
    result =
      BalanceLib.create_balance(
        [
          %{4 => 5, 1 => 8},
          %{2 => 6},
          %{3 => 7}
        ],
        2,
        mode: :loser_picks,
        rating_lower_boundary: 100,
        rating_upper_boundary: 100,
        mean_diff_max: 100,
        stddev_diff_max: 100,
        algorithm: @split_algo
      )

    assert result.team_players == %{1 => [4, 1], 2 => [2, 3]}

   end

  test "perform" do
     expanded_group = [
      %{count: 2, members: [100, 4], group_rating: 13, ratings: [8, 5]},
      %{count: 1, members: [2], group_rating: 6, ratings: [6]},
      %{count: 1, members: [3], group_rating: 7, ratings: [17]}
    ]

    result =
      SplitOneChevs.perform(expanded_group, 2)

    assert result = %{

      team_groups: %{
        1 => [
          %{count: 1, members: [3], ratings: [17], group_rating: 17},
          %{count: 1, members: [100], ratings: [8], group_rating: 8}
        ],
        2 => [
          %{count: 1, members: [2], ratings: [6], group_rating: 6},
          %{count: 1, members: [4], ratings: [5], group_rating: 5}
        ]
      },

      team_players: %{1 => [3, 100], 2 => [2, 4]},

    }

  end

  test "flatten members" do
    expanded_group = [
      %{count: 2, members: [100, 4], group_rating: 13, ratings: [8, 5]},
      %{count: 1, members: [2], group_rating: 6, ratings: [6]},
      %{count: 1, members: [3], group_rating: 7, ratings: [17]}
    ]

    result =
      SplitOneChevs.flatten_members(expanded_group)

    assert result == [
             %{rating: 8, rank: 4, member_id: 100},
             %{rating: 5, rank: 0, member_id: 4},
             %{rating: 6, rank: 0, member_id: 2},
             %{rating: 17, rank: 0, member_id: 3}
           ]
  end

  test "sort members" do
    members =[
      %{rating: 8, rank: 4, member_id: 100},
      %{rating: 5, rank: 0, member_id: 4},
      %{rating: 6, rank: 0, member_id: 2},
      %{rating: 17, rank: 0, member_id: 3}
    ]

    result =
      SplitOneChevs.sort_members(members)

    assert result ==[
      %{rating: 8, rank: 4, member_id: 100},
      %{rating: 17, rank: 0, member_id: 3},
      %{rating: 6, rank: 0, member_id: 2},
      %{rating: 5, rank: 0, member_id: 4}
    ]

  end

  test "assign teams" do
    members = [
      %{rating: 8, rank: 4, member_id: 100},
      %{rating: 5, rank: 0, member_id: 4},
      %{rating: 6, rank: 0, member_id: 2},
      %{rating: 17, rank: 0, member_id: 3}
    ]

    result =
      SplitOneChevs.assign_teams(members, 2)

    assert result.teams == [
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
  end

  test "create empty teams" do
    result =
      SplitOneChevs.create_empty_teams(3)

    assert result == [
             %{members: [], team_id: 1},
             %{members: [], team_id: 2},
             %{members: [], team_id: 3}
           ]
  end

  test "calculate standard deviation" do
    input = [8,5]
    result = Statistics.stdev(input);
    assert result==1.5
  end

  test "logs" do
    result =
      BalanceLib.create_balance(
        [
          %{1 => 5},
          %{2 => 6},
          %{3 => 7},
          %{4 => 8}
        ],
        4,
        algorithm: @split_algo
      )

      assert result.logs == ["User 4 picked for Team 1", "User 3 picked for Team 2", "User 2 picked for Team 3", "User 1 picked for Team 4"]
  end
end
