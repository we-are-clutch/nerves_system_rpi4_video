defmodule NervesSystemRpi4Video do
  @moduledoc """
  Documentation for `NervesSystemRpi4Video`.
  """

  @doc """
  Monkey patch Nerves to use clutch_nerves_system_br.
  """
  def patch_nerves do
    alias Nerves.Env, as: NervsEnv
    
    # Store original package function from Nerves.Env
    original_package = Function.capture(Nerves.Env, :package, 1)
    
    # Define our custom package lookup function
    custom_package = fn
      :nerves_system_br ->
        # Find clutch_nerves_system_br if nerves_system_br is requested
        clutch_package = Enum.find(Nerves.Env.packages(), &(&1.app == :clutch_nerves_system_br))
        
        if clutch_package do
          # Return clutch_nerves_system_br with :path set
          Map.put(clutch_package, :path, Path.join(File.cwd!(), "deps/clutch_nerves_system_br"))
        else
          # Fallback to original function
          original_package.(:nerves_system_br)
        end
      
      other_package ->
        # Use original function for all other packages
        original_package.(other_package)
    end
    
    # Apply the monkey patch using :meck
    try do
      :meck.new(Nerves.Env, [:passthrough, :unstick])
      :meck.expect(Nerves.Env, :package, custom_package)
      :ok
    rescue
      e -> 
        IO.puts("Failed to apply Nerves patch: #{inspect(e)}")
        :error
    end
  end
end 