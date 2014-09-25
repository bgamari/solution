suffixes = {
    G: 1e9,
    M: 1e6,
    k: 1e3,
    '': 1,
    m: 1e-3,
    u: 1e-6,
    n: 1e-9,
    p: 1e-12,
}

parse_quantity = (s, unit) ->
    m = /^([\-\+]?(?:[0-9]+(?:\.[0-9]+)?))\s*(\w*)$/.exec(s)
    if m == null
        return null
    else
        suffix = m[2]
        if suffix.length == 0
            mult = 1
        else if suffix == unit
            mult = 1
        else if suffix.length == 1 || suffix[1] == unit
            mult = suffixes[suffix[0]]
        else
            return null
        conc = parseFloat(m[1]) * mult

parse_input_quantity = (el, unit) ->
    if el.val() == ""
        return null
    q = parse_quantity(el.val(), unit)
    if q != null
        el.removeClass "bg-danger"
        el.val format_quantity(q, unit)
    else
        el.addClass "bg-danger"
    return q

format_quantity = (n, unit) ->
    for suffix, mult of suffixes
        nn = (n / mult).toFixed(1)
        if nn < 1000 && nn >= 1
            return nn + " " + suffix + unit
    return n.toFixed(3) + " " + unit

update = (ev) ->
    target_vol = parse_input_quantity($("#target-volume"), "L")
    solvent_vol = target_vol
    $("#components tr.component").each (n) ->
        el = $(this)
        el.addClass "inactive"
        stock = parse_input_quantity($(".stock", el), "M")
        if stock == null
            return

        desired = parse_input_quantity($(".desired", el), "M")
        if desired == null
            return

        if desired > stock
            el.addClass "warning"
            return

        el.removeClass "inactive"
        el.removeClass "warning"
        el.children().removeClass "bg-danger"
        vol = desired * target_vol / stock
        solvent_vol -= vol
        $(".volume", el).html(format_quantity(vol, "L"))

    $("#components tr.solvent .volume").html(format_quantity(solvent_vol, "L"))

arrow_move = (ev, self, klass) ->
    if ev.keyCode == 38 # up arrow
        offset = -1
    else if ev.keyCode == 40 # down arrow
        offset = 1
    else
        return

    rowIndex = self.parentElement.parentElement.rowIndex
    newRow = $("#components tr")[rowIndex + offset]
    $(klass, newRow).focus()

add_component = () ->
    item = $("<tr/>", { class: "component inactive" })

    del_btn = $("<button/>", {class: "btn btn-danger btn-xs delete"})
        .html("del")
    del_btn.click (ev) ->
        $(this.parentElement.parentElement).remove()
    item.append $("<td/>").append(del_btn)

    name = $("<input/>", {
                class: "name", type: "text",
                placeholder: "name"})
    name.attr('size', '18')
    name.keypress (ev) -> arrow_move(ev, this, ".name")
    item.append $("<td/>").append(name)

    conc = $("<input/>", {
                class: "concentration stock",
                placeholder: "concentration"})
    conc.attr('size', '9')
    conc.change update
    conc.keypress (ev) -> arrow_move(ev, this, ".stock")
    item.append $("<td/>").append(conc)

    conc = $("<input/>", {
                class: "concentration desired",
                placeholder: "concentration"})
    conc.attr('size', '9')
    conc.change update
    conc.keypress (ev) -> arrow_move(ev, this, ".desired")
    item.append $("<td/>").append(conc)

    item.append $("<td/>").append("<p/>").addClass("volume")

    item.keypress (ev) ->
        if ev.key == "d" && ev.altKey
            this.remove()
            update()

    $("#components tbody").append item
    return item

$(document).ready () ->
    $("#add-component").click add_component
    $("#target-volume").change update
    $(document).keypress (ev) ->
        if ev.key == "a" && ev.altKey
            item = add_component()
            $(".name", item).focus()

    add_component()
    update()
