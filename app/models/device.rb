# frozen_string_literal: true

class Device < ApplicationRecord
  has_many :capabilities, inverse_of: :device
  belongs_to :protocol
  accepts_nested_attributes_for :capabilities, reject_if: :all_blank, allow_destroy: true
  belongs_to :user

  scope :enabled, ->(user_id) {
    eager_load(:capabilities).where(user_id: user_id, enabled: true, capabilities: { enabled: true })
  }

  METROLOGY = [['t', 'Температура', 'C'], ['p', 'Давление', 'HPA'], ['h', 'Влажность', 'HUM']].freeze

  TYPES = [
    ['Лампочка, светильник, люстра.',                                'devices.types.light'                ],
    ['Розетка.',                                                     'devices.types.socket'               ],
    ['Выключатель, реле.',                                           'devices.types.switch'               ],
    ['Водонагреватель, теплый пол, обогреватель, электровентилятор.','devices.types.thermostat'           ],
    ['Кондиционер.',                                                 'devices.types.thermostat.ac'        ],
    ['Аудио, видео, мультимедиа техника.',                           'devices.types.media_device'         ],
    ['Телевизор, ИК-пульт от телевизора',                            'devices.types.media_device.tv'      ],
    ['ИК-пульт от тв-приставки, тв-приставка.',                      'devices.types.media_device.tv_box'  ],
    ['ИК-пульт от ресивера, ресивер.',                               'devices.types.media_device.receiver'],
    ['Различная умная кухонная техника.',                            'devices.types.cooking'              ],
    ['Кофеварка, кофемашина.',                                       'devices.types.cooking.coffee_maker' ],
    ['Чайник.',                                                      'devices.types.cooking.kettle'       ],
    ['Мультиварка.',                                                 'devices.types.cooking.multicooker'  ],
    ['Дверь, ворота, окно, ставни.',                                 'devices.types.openable'             ],
    ['Шторы, жалюзи.',                                               'devices.types.openable.curtain'     ],
    ['Увлажнитель воздуха.',                                         'devices.types.humidifier'           ],
    ['Очиститель воздуха.',                                          'devices.types.purifier'             ],
    ['Робот-пылесос.',                                               'devices.types.vacuum_cleaner'       ],
    ['Стиральная машина.',                                           'devices.types.washing_machine'      ],
    ['Посудомоечная машина.',                                        'devices.types.dishwasher'           ],
    ['Утюг, парогенератор.',                                         'devices.types.iron'                 ],
    ['Датчик температуры, влажности, открытия двери, движения.',     'devices.types.sensor'               ],
    ['Остальные устройства.',                                        'devices.types.other'                ]
  ].freeze

  PINS = [
    { id:  1, bg: 'warning',   num: nil, comment: '3v3'       }, { id:  2, bg: 'danger',    num: nil, comment: '5v0'       },
    { id:  3, bg: 'primary',   num: 2,   comment: 'SDA'       }, { id:  4, bg: 'danger',    num: nil, comment: '5v0'       },
    { id:  5, bg: 'primary',   num: 3,   comment: 'SCL'       }, { id:  6, bg: 'secondary', num: nil, comment: 'GND'       },
    { id:  7, bg: 'success',   num: 4,   comment: 'GPCLK0'    }, { id:  8, bg: 'light',     num: 14,  comment: 'TXD'       },
    { id:  9, bg: 'secondary', num: nil, comment: 'GND'       }, { id: 10, bg: 'light',     num: 15,  comment: 'RXD'       },
    { id: 11, bg: 'success',   num: 17,  comment: 'SPI CE1'   }, { id: 12, bg: 'success',   num: 18,  comment: 'SPI CE0'   },
    { id: 13, bg: 'success',   num: 27,  comment: '-'         }, { id: 14, bg: 'secondary', num: nil, comment: 'GND'       },
    { id: 15, bg: 'success',   num: 22,  comment: '-'         }, { id: 16, bg: 'success',   num: 23,  comment: '-'         },
    { id: 17, bg: 'warning',   num: nil, comment: '3v3'       }, { id: 18, bg: 'success',   num: 24,  comment: '-'         },
    { id: 19, bg: 'info',      num: 10,  comment: 'SPI0 MOS'  }, { id: 20, bg: 'secondary', num: nil, comment: 'GND'       },
    { id: 21, bg: 'info',      num: 9,   comment: 'SPI0 MISO' }, { id: 22, bg: 'success',   num: 25,  comment: '-'         },
    { id: 23, bg: 'info',      num: 11,  comment: 'SPI0 SCLK' }, { id: 24, bg: 'info',      num: 8,   comment: 'SPI0 CE0'  },
    { id: 25, bg: 'secondary', num: nil, comment: 'GND'       }, { id: 26, bg: 'info',      num: 7,   comment: 'SPI0 CE1'  },
    { id: 27, bg: 'primary',   num: 0,   comment: 'ID_SD'     }, { id: 28, bg: 'primary',   num: 1,   comment: '-'         },
    { id: 29, bg: 'success',   num: 5,   comment: '-'         }, { id: 30, bg: 'secondary', num: nil, comment: 'GND'       },
    { id: 31, bg: 'success',   num: 6,   comment: '-'         }, { id: 32, bg: 'success',   num: 12,  comment: 'PWM0'      },
    { id: 33, bg: 'success',   num: 13,  comment: 'PWM1'      }, { id: 34, bg: 'secondary', num: nil, comment: 'GND'       },
    { id: 35, bg: 'info',      num: 19,  comment: 'SPI1 MISO' }, { id: 36, bg: 'success',   num: 16,  comment: 'SPI1 CE2'  },
    { id: 37, bg: 'success',   num: 26,  comment: '-'         }, { id: 38, bg: 'info',      num: 20,  comment: 'SPI1 MOSI' },
    { id: 39, bg: 'secondary', num: nil, comment: 'GND'       }, { id: 40, bg: 'info',      num: 21,  comment: 'SPI1 SCLK' }
  ].freeze

  INFO = {
    mac: `ifconfig`.split('ether ')[1][0..16],
    owner: 'dvitvitskiy.pro@gmail.com'
  }.freeze

  def self.narod_mon
    bme280_1 = JSON.parse RestClient.get('krsz.ru:3005/bme280')
    bme280_2 = JSON.parse RestClient.get('krsz.ru:3005/bme280_2')
    data_1 = Device::METROLOGY.map { |v| { id: v[0], name: v[1], value: bme280_1[v[0]], unit: v[2] } }
    data_2 = Device::METROLOGY.map { |v| { id: v[0], name: v[1], value: bme280_2[v[0]], unit: v[2] } }
    devices = [
      INFO.merge(sensors: data_1, name: 'Bosch_BME280'),
      INFO.merge(sensors: data_2, name: 'Bosch_BME280_2')
    ]
    RestClient.post('http://narodmon.ru/post', { devices: devices }.to_json)
  end

  def self.user_devices(user_id)
    enabled(user_id).map do |d|
      {
        id: d.id.to_s,
        name: d.name,
        description: d.description,
        room: d.room,
        type: d.device_type,
        custom_data: {},
        device_info: { manufacturer: d.manufacturer, model: d.model, hw_version: d.hw_version, sw_version: d.sw_version },
        capabilities: d.capabilities.map { |cap| self.capability(cap) }
      }
    end
  end

  def self.user_query(user_id)
    enabled(user_id).map do |d|
      {
        id: d.id.to_s, capabilities: d.capabilities.map do |cap|
          { type: cap.capability_type, state: { instance: cap.state_instance, value: true } }
        end
      }
    end
  end

  def device_info
    {
      manufacturer: manufacturer,
      model: model,
      hw_version: hw_version,
      sw_version: sw_version
    }
  end

  private

  def self.capability(cap)
    capability = { type: cap.capability_type, retrievable: cap.retrievable }
    if cap.capability_type == 'devices.capabilities.range'
      capability[:parameters] = {
          instance: 'open',
          unit: 'unit.percent',
          random_access: true,
          range: {
              min: 0,
              max: 100,
              precision: 1
          }
      }
    end
    capability
  end
end
