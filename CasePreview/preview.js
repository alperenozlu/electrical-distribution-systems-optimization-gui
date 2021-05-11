var SETTINGS = {
    COLORS: {
        DEFAULT: '#000',
        DGANDBATTERY: '#FF9933',
        TAPCHANGER: '#CC0066'
    },
    PREFIX: {
        NODE: 'node_',
        PATH: 'path_'
    }
}

var selectedNodes = {
    tc: [],
    dg: [] // dg or battery
}

function setup(htmlComponent) {




    var ellipses = document.getElementsByTagName('ellipse');
    var paths = document.getElementsByTagName('path');

    htmlComponent.addEventListener("DataChanged", function (event) {

        try {
            var data = htmlComponent.Data.toString().split(','); // example data  "tc,1,2,3"
            var type = data[0]; // dc, tc, battery etc...

                // Reset previous selected of given type
                selectedNodes[type] = [];

                // Set all bus color to default color for each coming data    
                for (var i = 1; i <= ellipses.length; i++) {
                    var target = document.getElementById(SETTINGS.PREFIX.NODE + i);
                    if (target) {
                        target.style.fill = SETTINGS.COLORS.DEFAULT;
                    }
                }

                // Set all line color to default color for each coming data
                for (var i = 1; i <= paths.length; i++) {
                    var target = document.getElementById(SETTINGS.PREFIX.PATH + i);
                    if (target) {
                        target.style.stroke = SETTINGS.COLORS.DEFAULT;
                    }
                }

                // Set selected indexes of given type
                for (var i = 1; i < data.length; i++) {
                    var nodeIndex = data[i];

                    if (selectedNodes[type].indexOf(nodeIndex) === -1) {
                        selectedNodes[type].push(nodeIndex);
                    }

                }


                // Set DGs
                for (var i = 0; i < selectedNodes.dg.length; i++) {
                    var nodeIndex = selectedNodes.dg[i];
                    var target = document.getElementById(SETTINGS.PREFIX.NODE + nodeIndex);
                    if (target) {
                        target.style.fill = SETTINGS.COLORS.DGANDBATTERY;
                    }
                }


                // Set Tap Changers
                for (var i = 0; i < selectedNodes.tc.length; i++) {
                    var nodeIndex = selectedNodes.tc[i];
                    var target = document.getElementById(SETTINGS.PREFIX.PATH + nodeIndex);
                    if (target) {
                        target.style.stroke = SETTINGS.COLORS.TAPCHANGER;
                    }
                }
          
        } catch (e) {
            alert(e.toString())
        }

    });
}
