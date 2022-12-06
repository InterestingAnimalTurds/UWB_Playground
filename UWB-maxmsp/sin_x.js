
const maxApi = require('max-api')



maxApi.addHandler('getYposition',(range_a,range_b,dist_c) =>{

    let a = range_a;
    let b = range_b;
    let c = dist_c;
    let cos_a = (b*b + c*c - a*a)/(2 * b * c);
    let x_position = b * cos_a;

    let sin_a = Math.sqrt(1 - cos_a * cos_a);
    let y_position = b  *  sin_a;

    maxApi.post(y_position);
    maxApi.outlet(y_position);
});