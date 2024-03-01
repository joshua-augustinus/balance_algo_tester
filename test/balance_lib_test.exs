defmodule Teiserver.Battle.BalanceLibTest do
  use ExUnit.Case, async: false
  alias Teiserver.Battle.BalanceLib
  alias Teiserver.Battle.Logger

  test "loser picks simple users" do
    result =
      BalanceLib.create_balance(
        [
          %{1 => 5},
          %{2 => 6},
          %{3 => 7},
          %{4 => 8}
        ],
        2,
        mode: :loser_picks
      )
      |> Map.drop([:logs, :time_taken])

    assert result == %{
             team_groups: %{
               1 => [
                 %{members: [4], count: 1, group_rating: 8, ratings: [8]},
                 %{members: [1], count: 1, group_rating: 5, ratings: [5]}
               ],
               2 => [
                 %{members: [3], count: 1, group_rating: 7, ratings: [7]},
                 %{members: [2], count: 1, group_rating: 6, ratings: [6]}
               ]
             },
             team_players: %{
               1 => [4, 1],
               2 => [3, 2]
             },
             ratings: %{
               1 => 13,
               2 => 13
             },
             captains: %{
               1 => 4,
               2 => 3
             },
             team_sizes: %{
               1 => 2,
               2 => 2
             },
             deviation: 0,
             means: %{1 => 6.5, 2 => 6.5},
             stdevs: %{1 => 1.5, 2 => 0.5},
           }
  end

  test "split one chevs simple users" do
    result =
      BalanceLib.create_balance(
        [
          %{1 => 5},
          %{2 => 6},
          %{3 => 7},
          %{4 => 8}
        ],
        2,
        algorithm: "split_one_chevs"
      )
      |> Map.drop([:logs, :time_taken])


   end

   test "loser picks bad balance" do
    result =
      BalanceLib.create_balance(
        [
          %{100 => 21},
          %{101 => 2},
          %{3 => 17},
          %{4 => 18}
        ],
        2,
        algorithm: "loser_picks"
      )
      |> Map.drop([:logs, :time_taken])


      assert result.team_groups == %{
        1 => [
          %{count: 1, members: [100], group_rating: 21, ratings: [21]},
          %{count: 1, members: [101], group_rating: 2, ratings: [2]}
        ],
        2 => [
          %{count: 1, members: [4], group_rating: 18, ratings: [18]},
          %{count: 1, members: [3], group_rating: 17, ratings: [17]}
        ]
      }
   end

   test "split one chevs with noobs" do
    # Any user with id less than 5 is a one chev
    # With the real codebase, the chev rank is pulled from DB but here it is mocked
    result =
      BalanceLib.create_balance(
        [
          %{100 => 21},
          %{101 => 2},
          %{3 => 17},
          %{4 => 18}
        ],
        2,
        algorithm: "split_one_chevs"
      )
      |> Map.drop([:logs, :time_taken])


      assert result.team_groups == %{
        1 => [
          %{count: 1, members: [3], group_rating: 17, ratings: [17]},
          %{count: 1, members: [100], group_rating: 21, ratings: [21]}
        ],
        2 => [
          %{count: 1, members: [4], group_rating: 18, ratings: [18]},
          %{count: 1, members: [101], group_rating: 2, ratings: [2]}
        ]
      }
   end

end
