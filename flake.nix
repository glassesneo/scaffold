{
  description = "A collection of project templates";

  outputs = {...}: {
    templates = {
      zig = {
        path = ./zig;
        description = "A simple Zig development environment";
      };
    };
  };
}
