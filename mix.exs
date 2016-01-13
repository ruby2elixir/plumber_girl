defmodule PlumberGirl.Mixfile do
  use Mix.Project

  @version "0.9.6"

  def project do
    [app: :plumber_girl,
     version: @version,
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     docs: [extras: ["README.md"]],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_spec, "~> 1.0", only: :test},
      {:earmark, "~> 0.2", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end


  defp package do
    [
     maintainers: ["Roman Heinrich", "Zohaib Rauf", "Remigiusz Jackowski"],
     licenses: ["MIT License"],
     description: "PlumberGirl takes care of your Elixir piping issues!",
     links: %{
       github: "https://github.com/ruby2elixir/plumber_girl",
       docs: "http://hexdocs.pm/plumber_girl/#{@version}/"
     }
    ]
  end
end
