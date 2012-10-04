'use strict';

/* Filters */
var Evaluators = {};

Evaluators.range = function(input, evaluation)
{
    var property = input[evaluation.property];
    if(property)
    {
        return (property >= evaluation.params.min) && (property <= evaluation.params.max);
    }else{
        return true;
    }
}

Evaluators.today = function(input, evaluation)
{
    var property = input[evaluation.property];
    if(property)
    {
        var current_time = new Date().getTime();   
        return (parseInt(current_time/(3600 * 24 * 1000)) == parseInt(property/(3600 * 24 * 1000 )));
    }else{
        return true;
    }
}

Evaluators.compare = function(input, evaluation)
{
    var property = input[evaluation.property];
    if(property)
    {
        var compare = "'" + property + "'" + evaluation.params.operator + "'" + evaluation.params.value + "'";
        return eval(compare);
    }else{
        
        return true;
    }
}

Evaluators.like = function(input, evaluation)
{
    var property = input[evaluation.property];
    if(property)
    {
        var reg = new RegExp(evaluation.params.value.toLowerCase());
        return reg.test(property.toLowerCase());
    }else{
        return true;
    }
}

function evaluation(input, evaluation){
    var evaluator = Evaluators[evaluation.type];
    if($.isFunction(evaluator))
    {
        
        return evaluator(input, evaluation);
    }else{
        alert("Evaluator doesn't exist.");
        return true;
    }
    
}
