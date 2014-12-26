$(document).ready(function() {
    var url = '/index.json';
    $.ajax({
        url: url,
        //data: {},
        dataType: "json",
        success: fill_typeahead,
    });
    // load index.json and fill the keyword (later this can be delayd for when the user starts to type, I think.
});

var keyword_mapping = new Array;

function fill_typeahead(data, status, jqXHR) {
    keyword_mapping = data;
    var keywords = new Array;
    //console.log(data);
    var i = 0;
    for (var prop in data) {
        keywords[i] = prop;
        i++;
    }
    $('#typeahead').typeahead( { 'source' : keywords, items : 15  });
}


var show_automatically = false;

function mysearch(keyword, auto) {
    var url = '/search';
    show_automatically = auto;
    //console.log("Keyword: " + keyword);

    data = keyword_mapping[keyword];

    var count = 0;
    if (! data) {
        $('.modal-body').html(keyword + ' Not found');
        $('#myModal').modal('show')
        return false;
    }

    var single;
    var html = '<ul>';
    for (var i = 0; i < data.length; i++) {
        count++;
        single = data[i]["url"];
        html += '<li><a href="' + data[i]["url"] + '">';
        html += data[i]["title"] + '</a></li>';
    }
    html += '</ul>';

    if (count == 0) {
       $('.modal-body').html('Not found');
       $('#myModal').modal('show')
    } else if (count == 1 && show_automatically) {
       window.location = single;
    } else {
       $('.modal-body').html(html);
       $('#myModal').modal('show')
    }

    return false;
}

$(".kw-button").click(function (e) {
    mysearch(e.target.value, false);
});

$("#typeahead").keyup(function (e) {
    if (e.keyCode == 13) {
        //console.log('----------');
        var keyword = $("#typeahead").val();

        mysearch(keyword, true);
    }
});

