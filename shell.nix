with import <nixpkgs> {};

mkShell {
    nativeBuildInputs = [
        gleam
        nodejs_20
        deno
    ];
}
