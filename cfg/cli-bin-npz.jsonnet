local pcbro = import "pcbro.jsonnet";
local g = import "pgraph.jsonnet";

// Return a wire-cell CLI sequence.
// This can be used with TLA from the command line like:
// wire-cell \
//   --tla-str infile="file.bin" \
//   --tla-str outfile="file.npz" \
//   -c cli-bin2npz.jsonent [...]
//
// infile may also be an array
function(infile, outfile, nplanes=3) {
    
    // Return graph to convert from pcbro .bin to .npz
    local graph = g.pipeline([pcbro.rawsource("input", infile, nplanes=nplanes),
                              pcbro.tentoframe("tensor-to-frame"),
                              pcbro.npzsink("output", outfile),
                              pcbro.dumpframes("dumpframes")]),

    local app = {
        type: 'Pgrapher',
        data: {
            edges: g.edges(graph)
        },
    },
    local cmdline = {
        type: "wire-cell",
        data: {
            plugins: pcbro.plugins + ["WireCellApps", "WireCellPgraph"],
            apps: ["Pgrapher"],
        }
    },
    seq: [cmdline] + g.uses(graph) + [app],
}.seq

