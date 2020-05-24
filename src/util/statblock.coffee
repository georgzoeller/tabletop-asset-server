module.exports.monsters = (result) ->
  block = "<stat-block  data-two-column style=\'--data-content-height: 50%;\'>
    <creature-heading>
      <h1>#{result.name}</h1>
      <h2>#{result.size} #{result.type}, #{result.alignment || 'unaligned' }</h2>
    </creature-heading>
    <top-stats>
      <property-line>
        <h4>Armor Class</h4>
        <p>#{result.ac}</p>
      </property-line>
      <property-line>
        <h4>Hit Points</h4>
        <p>#{result.hp} (#{result.hd})</p>
      </property-line>
      <property-line>
        <h4>Speed</h4>
        #{('<b>'+k+'</b>: '+v+'.&nbsp;')for k, v of result.speed}
      </property-line>

      <abilities-block data-str='#{result.str}'
                        data-dex='#{result.dex}'
                        data-con='#{result.con}'
                        data-int='#{result.int}'
                        data-wis='#{result.wis}'
                        data-cha='#{result.cha}'>
                        </abilities-block>
      <property-line>
        <h4>Damage Immunities</h4>
        <p>
        <p>#{((result.damage_immunities||[]).join(', '))}</p>
        </p>
      </property-line>
      <property-line>
        <h4>Condition Immunities</h4>
        <p>
        <p>#{((v.name) for k, v of result.condition_immunities).join(', ')}</p>
        </p>
      </property-line>
      <property-line>
      <h4>Senses</h4>
      <p>
      #{(('<p><b>'+k+'</b>: '+v+'</p>')for k, v of result.senses).join('')}
      </p>
      </property-line>
      <property-line>
        <h4>Languages</h4>
        <p>#{result.languages}</p>
      </property-line>
      <property-line>
        <h4>Challenge</h4>
        <p>#{result.cr}</p>
      </property-line>
      </top-stats>"

  if result.special_abilities?
    for sa in result.special_abilities
      block += "<property-block>
        <h4>#{sa.name}</h4>
        <p>#{sa.desc}</p>
      </property-block>"

  if result.actions?
    block += "<h3>Actions</h3>"
    for act in result.actions
      desc = act.desc.replace(/\s\+\s/gim, '+').replace(/\s\-\s/gim, '-')
      block += "<property-block>
        <h4>#{act.name}</h4>
        <p>#{desc}</p>
        </property-block>"

  block += "</stat-block>"
  block
