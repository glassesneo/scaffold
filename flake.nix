{
  description = "A collection of project templates";

  outputs = {...}: {
    templates = {
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
