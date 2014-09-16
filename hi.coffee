comp_n = 0
components = {}

on_load = () ->
    $("#add-component").click add_component

update_conc = (ev, n) ->
    t = ev.target.value
    m = /^([\-\+]?(?:[0-9]+(?:\.[0-9]+)?))\s*(\w*)$/.exec(t)
    if m == null
        $(comp+" input.conc").addClass "invalid"
    else
        suffixes = {
            m: 1e-3,
            u: 1e-6,
            n: 1e-9
        }
        if m[2] == ""
            mult = 1
        else
            mult = suffixes[m[2][0]]
        conc = parseFloat(m[1]) * mult
        $(comp+" input.conc").removeClass "invalid"

add_component = () ->
    item = $("<li/>", { id: "component-"+comp_n })
    item.append $("<input/>", {
                class: "name", type: "text",
                placeholder: "name", size: 20})

    conc = $("<input/>", {
                class: "conc",
                placeholder: "concentration",
                size: 8})
    conc.change (ev) -> update_conc(ev, comp_n)
    item.append conc

    $("#components").append item
    comp_n += 1

$(document).ready(on_load);
