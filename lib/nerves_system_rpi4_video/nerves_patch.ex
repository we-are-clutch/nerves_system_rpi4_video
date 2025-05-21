defmodule NervesSystemRpi4Video.NervesPatch do
  @moduledoc """
  Monkey patch for Nerves to use clutch_nerves_system_br instead of nerves_system_br.
  """

  def apply_patch do
    # Only apply the patch if we need to (clutch_nerves_system_br is in use)
    if Enum.any?(Nerves.Env.packages(), fn pkg -> pkg.app == :clutch_nerves_system_br end) do
      # Store the original package lookup function
      original_package_fn = Function.capture(Nerves.Env, :package, 1)
      
      # Define our override function
      custom_package_fn = fn
        :nerves_system_br ->
          # If asking for nerves_system_br, return clutch_nerves_system_br instead
          Enum.find(Nerves.Env.packages(), &(&1.app == :clutch_nerves_system_br))
        arg ->
          # For all other packages, use the original function
          original_package_fn.(arg)
      end
      
      # Apply the monkey patch if needed
      if Code.ensure_loaded?(:meck) do
        :meck.new(Nerves.Env, [:passthrough])
        :meck.expect(Nerves.Env, :package, custom_package_fn)
        IO.puts("Applied NervesSystemRpi4Video.NervesPatch to use clutch_nerves_system_br")
      else
        IO.puts("Cannot apply NervesSystemRpi4Video.NervesPatch: :meck not available")
      end
    end
  end
end 