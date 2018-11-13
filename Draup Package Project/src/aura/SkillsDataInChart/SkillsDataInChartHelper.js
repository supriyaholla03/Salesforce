({
    helperMethod : function(component,helper) {
        console.log('From helper');
        var opts=[];
        var action = component.get("c.getData");
        //var Countrywise = component.get("c.getDataWithoutSumation");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                //alert("From server: " + JSON.stringify(response.getReturnValue()));
                
                component.set("v.Totalskills",response.getReturnValue());
                var allValues =component.get("v.Totalskills");
                
                console.log(Object.keys(allValues));
                var countryArray = Object.keys(allValues);
                var o = [];
                countryArray.forEach(function(country){
                    var obj = {};
                    obj.countryName = country;
                    obj.checkbox = false;
                    o.push(obj);
                    
                }) ;
                component.set("v.Countries",o);
                /* alert(" Object.keys(data)"+allValues)
                for(var country in allValues){
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: country
                    });
                }
                 component.find(elementId).set("v.options", opts);*/
            }
            
            else if (state === "INCOMPLETE") {
                
                // do something
                
            }
            
                else if (state === "ERROR") {
                    
                    var errors = response.getError();
                    
                    if (errors) {
                        
                        if (errors[0] && errors[0].message) {
                            
                            console.log("Error message: " +
                                        
                                        errors[0].message);
                            
                        }
                        
                    } else {
                        
                        console.log("Unknown error");                        
                    }                   
                }
            
        });
        
        
        
        $A.enqueueAction(action);
        
        
    },
  
    setupChart3 : function(component) {
        var ctx=0;
        var result = {}; 
        var skillsObj = {};
        var country = component.get("v.selectedCountries");
        var data = component.get("v.Totalskills");
        /*if(country.length==1){
            
            for (var i in data) {
                if(i ==country ) {
                    console.log(data[i]);
                    var aa = data[i].skills;
                    aa.forEach(function(skills1){
                        for (var j in skills1) {
                            //console.log(obj);
                            skillsObj[j] = skills1[j];
                        }
                        
                    });
                }
                
            }
            
        }
        else{*/
            var skillsdata=[];
            
            
            for (var i in data){
                for(var j=0;j<country.length;j++){
                    if(country[j]==i){
                        var skillsArr = data[i].skills;
                        console.log(skillsArr);
                        skillsArr.forEach(function(skills1){
                            
                            for (var j in skills1) {
                                console.log(j);
                                if (skillsObj[j] != undefined) {
                                    skillsObj[j] += parseInt(skills1[j]);
                                }
                                else
                                {
                                    console.log('new');
                                    skillsObj[j] = parseInt(skills1[j]);
                                }
                            }
                            
                        });
                    }
                    console.log();
                }
            }
            console.log(JSON.stringify(skillsdata));
            console.log(skillsObj);
            /*skillsdata.forEach(function(skills1){
               for (var j in skills1) {
                    //console.log(obj);
                    result[j] = skills1[j];
                }
                
            });*/
            
        
        for (var i in skillsObj) {
            if (parseInt(skillsObj[i]) != 0) {
                result[i] = skillsObj[i];
            }
        }
        
        var dataMap={"chartLabels": Object.keys(result),
                     "chartData": Object.values(result)
                    }   
        var ctx = component.find('barChart').getElement();
        
        var barChart = new Chart(ctx ,{
            type: 'horizontalBar',
            data: {
                labels: dataMap.chartLabels,              
                datasets: [
                    {
                        label: '# of Skills',
                        backgroundColor: "rgb(255,165,0)",
                        
                        data: dataMap.chartData
                        
                    }
                    
                ]
                
                
            },	
            options: {
              /*  tooltips: {
        callbacks: {
            label: function(tooltipItem) {
                return "$" + Number(tooltipItem.xLabel) + " and so worth it !";
            }
        }
    },*/
                
                "animation": {
                    "duration": 1,
                    "onComplete": function() {
                        var chartInstance = this.chart,
                            ctx = chartInstance.ctx;
                        
                         ctx.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontSize, Chart.defaults.global.defaultFontStyle, Chart.defaults.global.defaultFontFamily);
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'bottom';
                       
                        this.data.datasets.forEach(function(dataset, i) {
                            var meta = chartInstance.controller.getDatasetMeta(i);
                            meta.data.forEach(function(bar, index) {
                                var data = dataset.data[index];
                                ctx.fillText(data, bar._model.x +15, bar._model.y);
                            });
                        });
                    }
                },
                
                
                scales: {
                    xAxes: [{
                        gridLines: {
                    color: "rgba(0, 0, 0, 0)",
                },
                         categoryPercentage: .4, 
			             barPercentage: 0.5,
                        position: 'top',
                        ticks: {
                            beginAtZero: true// Edit the value according to what you need
                        }
                    }],
                    yAxes: [{
                        gridLines: {
                    color: "rgba(0, 0, 0, 0)",
                },
                          categoryPercentage: .4, 
			             barPercentage: 0.5,
                        stacked: true
                    }]
                }                      
                
            } 
        }); 
        
        barChart.destroy();
        
        
        
    }
    
    
})