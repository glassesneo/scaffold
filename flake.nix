{
  description = "A collection of project templates";

  outputs = {...}: {
    templates = {
      minimal = {
        path = ./minimal;
        description = "A minimal environment";
      };
      moonbit = {
        path = ./moonbit;
        description = "A simple MoonBit development environment";
      };
      gcc = {
        path = ./gcc;
        description = "A simple GCC development environment";
      };
      go = {
        path = ./go;
        description = "A simple Go development environment";
      };
      node = {
        path = ./node;
        description = "A simple Node.js development environment";
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
