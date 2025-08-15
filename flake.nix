{
  description = "A collection of project templates";

  outputs = {...}: {
    templates = {
      minimal = {
        path = ./minimal;
        description = "A minimal environment";
      };
      haskell = {
        path = ./haskell;
        description = "A simple Haskell development environment";
      };
      typst = {
        path = ./typst;
        description = "A simple Typst environment with tdf";
      };
      zig = {
        path = ./zig;
        description = "A simple Zig development environment";
      };
    };
  };
}
