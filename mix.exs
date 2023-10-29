defmodule Blackjack.MixProject do
  use Mix.Project

  def project do
    [
      app: :blackjack,
      version: "0.1.1",
      elixir: "~> 1.15.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      preferred_cli_env: [espec: :test, coveralls: :test, "coveralls.html": :test],
      test_coverage: [tool: ExCoveralls, test_task: "espec"]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:espec, "~> 1.9.0", only: :test},
      {:excoveralls, "~> 0.18.0", only: :test}
    ]
  end

  defp escript do
    [
      main_module: Blackjack,
      emu_args: "-noinput -elixir ansi_enabled true"
    ]
  end
end
