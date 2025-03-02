defmodule Blackjack.MixProject do
  use Mix.Project

  def project do
    [
      app: :blackjack,
      version: "0.1.1",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      preferred_cli_env: [espec: :test]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:espec, "~> 1.9.0", only: :test}
    ]
  end

  defp escript do
    [
      main_module: Blackjack,
      emu_args: "-noinput -elixir ansi_enabled true"
    ]
  end
end
