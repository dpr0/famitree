import * as d3 from "d3"

var arrow_length = 120;
var root = gon.graph
if (root) {
    var i = 0, duration = 500, rectW = 240, rectH = 50;
    var innerWidth = window.innerWidth;
    var innerHeight = window.innerHeight;
    var tree = d3.layout.tree().nodeSize([rectW + 10, rectH + 10]);
    var diagonal = d3.svg.diagonal().projection(d => [d.x + rectW / 2, d.y + rectH / 2]);

    var svg = d3.select("#diag").append("svg").attr("width", innerWidth).attr("height", innerHeight)
        .call(zm = d3.behavior.zoom().scaleExtent([1, 3]).on("zoom", redraw)).append("g")
        .attr("transform", "translate(" + 50 + "," + 10 + ")");

    // zm.translate([50, 10]); //necessary so that zoom knows where to zoom and unzoom from

    root.x0 = 0;
    root.y0 = 0;
    root.children.forEach(collapse);
    update(root);
}
function collapse(d) {
    if (d.children) {
        d._children = d.children;
        d._children.forEach(collapse);
        d.children = null;
    }
}

function update(source) {
    var nodes = tree.nodes(root), links = tree.links(nodes);
    nodes.forEach( d => d.y = d.depth * arrow_length ); // Normalize for fixed-depth.
    var node = svg.selectAll("g.node").data(nodes, d => d.id || (d.id = ++i) ); // Update the nodes…
    var nodeEnter = node.enter().append("g") // Enter any new nodes at the parent's previous position.
        .attr("class", "node").attr("transform", d => "translate(" + source.x0 + "," + source.y0 + ")") .on("click", click);

    nodeEnter.append("rect")
        .attr("width", rectW).attr("height", rectH)
        .attr("stroke", "black").attr("stroke-width", 1)
        .style("fill", d => d.sex_id == 1 ? (d._children ? "#4FA9DC" : "#53c5ff") : (d._children ? "#CB86BF" : "#ffaef3"))
    // .on("mouseout",  d => {})
    // .on("mouseover", d => {})

    nodeEnter.append("text")
        .attr("x", rectW / 2).attr("y", rectH / 2 - 14)
        .attr("dy", ".35em").attr("text-anchor", "middle")
        .text(d => d.name);
    nodeEnter.append("text")
        .attr("x", rectW / 2).attr("y", rectH / 2)
        .attr("dy", ".35em").attr("text-anchor", "middle")
        .text(d => d.dates);
    nodeEnter.append("text")
        .attr("x", rectW / 2).attr("y", rectH / 2 + 14)
        .attr("dy", ".35em").attr("text-anchor", "middle")
        .text(d => d.relations);

    // nodeEnter.append("image")
    //     .attr("xlink:href", d => d.avatar)
    //     .attr("x", "1px").attr("y", "50px")
    //     .attr("height", "50px")

    // Transition nodes to their new position.
    var nodeUpdate = node.transition().duration(duration)
        .attr("transform", d => "translate(" + d.x + "," + d.y + ")");

    nodeUpdate.select("rect")
        .attr("width", rectW).attr("height", rectH)
        .attr("stroke", "black").attr("stroke-width", 1)
        .style("fill", d => d.sex_id == 1 ? (d._children ? "#4FA9DC" : "#53c5ff") : (d._children ? "#CB86BF" : "#ffaef3"));

    nodeUpdate.select("text").style("fill-opacity", 1);

    // Transition exiting nodes to the parent's new position.
    var nodeExit = node.exit().transition().duration(duration)
        .attr("transform", d => "translate(" + source.x + "," + source.y + ")").remove();

    // nodeExit.select("rect")
    //     .attr("width", rectW /2).attr("height", rectH)
    //     .attr("stroke", "black").attr("stroke-width", 1);
    // nodeExit.select("text");

    var link = svg.selectAll("path.link").data(links, d => d.target.id); // Update the links…

    // Enter any new links at the parent's previous position.
    link.enter().insert("path", "g")
        .attr("class", "link")
        .attr("x", rectW / 2).attr("y", rectH / 2)
        .attr("d", d => {
            var o = { x: source.x0, y: source.y0 };
            return diagonal({ source: o, target: o });
        });

    // Transition links to their new position.
    link.transition().duration(duration).attr("d", diagonal);

    // Transition exiting nodes to the parent's new position.
    link.exit().transition().duration(duration)
        .attr("d", d => {
            var o = { x: source.x, y: source.y };
            return diagonal({ source: o, target: o });
        }).remove();

    nodes.forEach(d => { d.x0 = d.x; d.y0 = d.y; }); // Stash the old positions for transition.
}

function click(d) {
    if (d.children) {
        d._children = d.children;
        d.children = null;
        // d3.select("#tt_01").transition().delay(1000).style('opacity', 0)
        d3.select("#tt_01").transition().style('opacity', 0)
    } else {
        d.children = d._children;
        d._children = null;
    }
    d3.select("#tt_01").style("left", "30px").style("top", "30px");
    d3.select("#value_tt_01").text(d.address);
    d3.select("#info_tt_01").text(d.info);
    if (d.avatar && d.avatar.length > 0) d3.select("#img_tt_01").attr("src", d.avatar).attr("height", 200);
    d3.select('#link_tt_01').attr("href", d.url).text('Показать профиль персоны');
    d3.select('#predki_tt_01').selectAll("*").remove();
    if (d.rel_predki.length > 0) {
        d3.select('#predki_tt_01').append('p').text('Дерево супруга/супруги:');
        d.rel_predki.forEach(predok => {
            d3.select('#predki_tt_01').append('p').append('a').attr("href", `/persons/${predok.id}/graph`).text(`- ${predok.last_name}`);
        });
    }
    d3.select("#tt_01").style('opacity', 1);
    update(d);
}

function redraw() { // Redraw for zoom
    svg.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")");
}