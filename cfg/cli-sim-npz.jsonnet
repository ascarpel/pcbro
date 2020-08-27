// Use a simple line source for depos, run WCT sim, save as Numpy file

local pcbro = import "pcbro.jsonnet";
local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";

function(outfile, tag="", nplanes=3, resp=pcbro.response_file) {

    local det = pcbro.detector(resp),

    local tracklist = [
        {
            time: 0*wc.ms,
            charge: -5000,
            ray: {
                tail: wc.point(20, -10, -10, wc.cm),
                head: wc.point(30, +10, +10, wc.cm),
            }
        }],

    local depos = g.pnode({
        type: 'TrackDepos',
        data: {
            step_size: 1.0*wc.mm,
            tracks: tracklist
        },
    }, nin=0, nout=1),

    local graph = g.pipeline([
        depos,
        pcbro.sim(det),
        // pcbro.sigproc(det),
        pcbro.npzsink("output", outfile, false, tags=["orig0"]),
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
            plugins: pcbro.plugins + ["WireCellApps", "WireCellPgraph", "WireCellGen"],
            apps: ["Pgrapher"],
        }
    },
    seq: [cmdline] + g.uses(graph) + [app],
}.seq

