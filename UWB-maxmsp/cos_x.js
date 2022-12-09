
const maxApi = require('max-api')


maxApi.addHandler('getXposition',(range_a,range_b,dist_c) =>{

    let a = range_a;
    let b = range_b;
    let c = dist_c;
    let cos_a = (b*b + c*c - a*a)/(2 * b * c);
    let x_position = b * cos_a;



    maxApi.post(x_position);
    maxApi.outlet(x_position);
});

