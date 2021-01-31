const addresses = {
    'oracle': '0x7525D619F2A01aea8ADc92cDD06152b25267c765',
    'USMv0.1': '0x21453979384f21D09534f8801467BDd5d90eCD6C',
    'FUMv0.1': '0x96F8F5323Aa6CB0e6F311bdE6DEEFb1c81Cb1898',
    'USMv0.2': '0xf05627D4F72bC4778BAECcbeaCa44b013e9b8227',
    'FUMv0.2': '0xe13b57555e5a538785130fda6e918185b9fe1599',
}
  
module.exports = [
    addresses['oracle'],
    [
        addresses['USMv0.1'],
        addresses['FUMv0.1'],
        addresses['USMv0.2'],
        addresses['FUMv0.2'],
    ],
];