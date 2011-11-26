function setPreview(dropdown) {
    var myIndex = dropdown.selectedIndex
    var setText = dropdown.options[myIndex].text
    var setTextArr = setText.split(" for ")
    setText = setTextArr[setTextArr.length-1]
    setTextArr = setText.split(" - ")
    setText = setTextArr[0]
    setText = setText.toLowerCase().replace(/ /g,"_")
    $('#previewCard').attr("src", "/assets/images/cards/"+setText+'.jpg');
    $('#previewCard').attr('alt', setText+'.jpg');
}

function setAllSites()  {
    $('#rep_properties').each(function() {
        $('#rep_properties option').attr("selected","selected");
    });
}

function flipMe(originNode,destinationName) {
    var children = originNode.parents('.tokens').children();
    originNode.parents('.tokens').children('.'+destinationName).css('display', 'block');
    children.not('.'+destinationName).css('display', 'none');
}
