const { stat } = require("fs");

let variableList = [{ segment: "vendor", option: "Dispatch" }, { segment: "vendor", option: "Marketplace" }];
let repeatCode = "";
let baseCode = "";
const booking_date = '2023-01-01';
const return_date = '2023-01-01';
const status = '%Cancel%';

function generateRepeatCode() {
    console.log('Generating code to get the on-rent data');

    for (let i = 0; i < variableList.length; i++) {
        // console.log(variableList[i].segment);
        // console.log(variableList[i].option);
    
        let injectCode = `LOWER(${variableList[i].segment}) LIKE LOWER('${variableList[i].option}')`;
        let fileName = `${variableList[i].option}`.toLowerCase();
        let comma = `,`;

        //remove comma for final version because of SQL syntax
        if (i === variableList.length - 1) {
            comma = '';
        };
    
        let templateCode = `
            SUM(
                CASE
                    WHEN ct.calendar_date = km.pickup_date AND ${injectCode} THEN km.pickup_fraction_of_day
                    WHEN ct.calendar_date = km.return_date AND ${injectCode} THEN km.return_fraction_of_day
                    WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND ${injectCode} THEN 1
                    ELSE 0
                END
            ) AS vendor_on_rent_${fileName}${comma}
            `;
    
        repeatCode += templateCode;
    
    };

    // console.log(repeatCode);
    return(generateBaseCode(repeatCode));
};

function generateBaseCode(repeatCode) {
    baseCode = `
        SELECT 
            DATE_FORMAT(DATE(ct.calendar_date), '%Y-%m-%d') AS calendar_date,
            
            -- MARKETPLACE VS DISPATCH
            ${repeatCode}

        FROM calendar_table ct

        INNER JOIN
        key_metrics_base km
        ON ct.calendar_date >= '${booking_date}'
        AND km.return_date >= '${return_date}'
        AND ct.calendar_date >= km.booking_date
        AND ct.calendar_date <= km.return_date
        AND km.status NOT LIKE '${status}'

        GROUP BY ct.calendar_date

        ORDER BY ct.calendar_date ASC

        -- LIMIT 5;
    `;


    // console.log(baseCode);
    return baseCode;
};

module.exports = {
    generateRepeatCode
}
