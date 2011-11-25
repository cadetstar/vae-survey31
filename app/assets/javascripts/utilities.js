function setPreview(dropdown) {
    var myIndex = dropdown.selectedIndex
    var setText = dropdown.options[myIndex].text
    var setTextArr = setText.split(" for ")
    setText = setTextArr[setTextArr.length-1]
    setTextArr = setText.split(" - ")
    setText = setTextArr[0]
    setText = setText.toLowerCase().replace(/ /g,"_")
    document.getElementById('previewCard').setAttribute('src','/images/cardexamples/'+setText+'.jpg')
    document.getElementById('previewCard').setAttribute('alt',setText+'.jpg')
}

function setAllSites()  {
    var siteObject = document.getElementById('rep_properties');
    for (i=0; i<siteObject.options.length; i++) {
        siteObject.options[i].selected = true;
    }
}

function flipMe(originNode,destinationName) {
    var children = originNode.parent.parent.childElements;
    var perNode;
    for (i=0;i<children.length;i++) {
        perNode = children[i];
        if (perNode.name == destinationName) {
            perNode.display = 'block';
        } else {
            perNode.display = 'none';
        }
    }
}