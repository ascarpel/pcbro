// Easy peasy noise filter related to the pnodes,

local g = import 'pgraph.jsonnet';
local wc = import 'wirecell.jsonnet';


function( anode, chndbobj,  name='' )
{

  local single = {
    type: 'pdOneChannelNoise',
    name : name,
    data : {
      noisedb: wc.tn(chndbobj),
      anode : wc.tn(anode),
    },
  },

  local grouped = {
    type: 'mbCoherentNoiseSub',
    name: name,
    data: {
      noisedb: wc.tn(chndbobj),
      anode: wc.tn(anode),
      rms_threshold: 0.0,
    },
  },

  make_nf(anode) :: g.pnode({
    type : 'OmnibusNoiseFilter',
    name : name,
    data : {
      nticks : 0,
      channel_filters : [
        wc.tn(single)
      ],
      grouped_filters : [
        // wc.tn(grouped)
      ],
      noisedb : wc.tn(chndbobj),
      intraces : 'orig%d' % anode.data.ident,
      outtraces : 'raw%d' % anode.data.ident,
    },
  }, uses=[chndbobj, anode, single, grouped], nin=1, nout=1 ),

}
