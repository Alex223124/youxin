class Version
  class << self
    def avatars
      [
        {
          name: :mobile,
          process: :resize_to_fill,
          dimension: [150, 150]
        },
        {
          name: :small,
          process: :resize_to_fill,
          dimension: [50, 50]
        },
        {
          name: :normal,
          process: :resize_to_fill,
          dimension: [80, 80]
        },
        {
          name: :big,
          process: :resize_to_fill,
          dimension: [130, 130]
        },
        {
          name: :huge,
          process: :resize_to_fill,
          dimension: [200, 200]
        },
        # For retina
        {
          name: :retina_small,
          process: :resize_to_fill,
          dimension: [100, 100]
        },
        {
          name: :retina_normal,
          process: :resize_to_fill,
          dimension: [160, 160]
        },
        {
          name: :retina_big,
          process: :resize_to_fill,
          dimension: [260, 260]
        },
        {
          name: :retina_huge,
          process: :resize_to_fill,
          dimension: [400, 400]
        }
      ]
    end
    def headers
      [
        {
          name: :ipad,
          process: :resize_to_fill,
          dimension: [626, 313]
        },
        {
          name: :mobile_retina,
          process: :resize_to_fill,
          dimension: [640, 320]
        },
        {
          name: :mobile,
          process: :resize_to_fill,
          dimension: [320, 160]
        },
        {
          name: :web_retina,
          process: :resize_to_fill,
          dimension: [1040, 520]
        },
        {
          name: :ipad_retina,
          process: :resize_to_fill,
          dimension: [1252, 626]
        },
        {
          name: :web,
          process: :resize_to_fill,
          dimension: [520, 260]
        }
      ]
    end
    def logos
      [
        {
          name: :normal,
          process: :resize_to_fill,
          dimension: [270, 100]
        }
      ]
    end
  end
end
