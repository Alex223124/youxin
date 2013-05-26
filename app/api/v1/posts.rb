class Posts < Grape::API
  before { authenticate! }

  resource :posts do
    desc "Create a post."
    post do
      bulk_authorize! :create_youxin, Organization.where(:id.in => params[:organization_ids])
      required_attributes! [:body_html, :organization_ids]

      attrs = attributes_for_keys [:title, :body_html, :organization_ids, :attachment_ids]
      post = current_user.posts.new attrs
      if post.save
        present post, with: Youxin::Entities::Post
      else
        fail!(post.errors)
      end
    end

    segment '/:id' do
      resource :forms do
        get do
          post = current_user.receipts.find_by(post_id: params[:id]).try(:post)
          if post
            present post.forms, with: Youxin::Entities::Form
          else
            not_found!
          end
        end
      end
    end

  end
end