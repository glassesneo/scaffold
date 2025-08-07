{
  description = "A collection of project templates";

  outputs = {...}: {
    templates = {
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
