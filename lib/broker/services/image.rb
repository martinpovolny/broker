module Broker
module ImageService
  class << self
    def get_images(authctx)
      image = Image.select_all.all
    end

    def get_frontend_images(authctx)
      images = Image.order(:broker_image_id).distinct(:broker_image_id).all
    end

    def get_image(authctx, image_id)
      image = Image[image_id]
      raise NotFound if image.nil?
      image
    end

    def delete_image(authctx, image_id)
      image = Image[params[:id]]
      raise NotFound if image.nil?
      image.delete
    end

    def create_image(authctx, image_params)
      image = Image.create(check_image_params(image_params))
    end

    def modify_image(authctx, image_params)
      image = Image[image_params[:id]] rescue nil
      raise NotFound if image.nil?

      #image = check_image(image_params[:image_id])

      Pool.update(check_image_params(image_params))
    end

    # to be implemented if other image management is used
    # such as ImageFactory / TIM
    def find_provider_image_id(provider_id, broker_image_id)
      image = Image.find(:provider_id => provider_id, :broker_image_id => broker_image_id)
      raise NotFound.new('provider image not found') if image.nil?
      image.provider_image_id
    end

    private
    def check_image_params(image_params)
      image_params.select do |key,_|
        [:broker_image_id, :provider_image_id, :provider_id].index(key)
      end
    end
  end
end
end

