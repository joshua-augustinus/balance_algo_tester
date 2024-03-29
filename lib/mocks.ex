# A set of modules to mock various other Teiserver modules
defmodule Central.Config do
  def get_site_config_cache("teiserver.Max deviation"), do: 10
end

defmodule Teiserver.Data.Types do
  @type userid() :: non_neg_integer()
end

defmodule Teiserver.Account do
  def get_username_by_id(userid) do
    "User##{userid}"
  end

  @spec get_rating(Integer.t() | List.t()) :: Rating.t()
  @spec get_rating(Integer.t(), List.t()) :: Rating.t()
  def get_rating(_args) do
    %{}
  end

  def get_rating(user_id, rating_type_id)
      when is_integer(user_id) and is_integer(rating_type_id) do
    %{}
  end

  def get_user_stat_data(_userid) do
    %{}
  end
end

defmodule Teiserver.Game.MatchRatingLib do
  @rated_match_types ["Team"]

  @spec rating_type_list() :: [String.t()]
  def rating_type_list() do
    @rated_match_types
  end

  @spec rating_type_id_lookup() :: %{Integer.t() => String.t()}
  def rating_type_id_lookup() do
    %{1 => "Team"}
  end

  @spec rating_type_name_lookup() :: %{String.t() => Integer.t()}
  def rating_type_name_lookup() do
    %{"Team" => 1}
  end
end

defmodule Central.Helpers.NumberHelper do
  @spec int_parse(String.t() | nil | number() | List.t()) :: Integer.t() | List.t()
  def int_parse(""), do: 0
  def int_parse(nil), do: 0
  def int_parse(i) when is_number(i), do: round(i)
  def int_parse(l) when is_list(l), do: Enum.map(l, &int_parse/1)
  def int_parse(s), do: String.trim(s) |> String.to_integer()

  @spec round(number(), non_neg_integer()) :: integer() | float()
  def round(value, decimal_places) do
    dp_mult = :math.pow(10, decimal_places)
    round(value * dp_mult) / dp_mult
  end
end

defmodule Teiserver.CacheUser do
  def calculate_rank(userid, "Playtime") do
    ingame_hours = rank_time(userid)

    [5, 15, 30, 100, 300, 1000, 3000]
    |> Enum.count(fn r -> r <= ingame_hours end)
  end

  @moduledoc """
   If your userid contains the word noob then your time is 0
   Otherwise you've played for 5 hours
  """
  def rank_time(userid) when is_bitstring((userid)) do
    if String.contains?(userid, "noob") do
      0
    else
      5
    end
  end

  def rank_time(_userid) do
    5
  end
end
