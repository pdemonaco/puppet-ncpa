type Ncpa::PluginFile = Hash[
  Enum[
    'name',
    'content',
  ],
  Variant[
    String,
    Ncpa::SourceUrl,
  ],
]
