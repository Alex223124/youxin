require 'spec_helper'

describe ReceiptsController do

  def valid_attributes
    {  }
  end

  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all receipts as @receipts" do
      receipt = Receipt.create! valid_attributes
      get :index, {}, valid_session
      assigns(:receipts).should eq([receipt])
    end
  end

  describe "GET show" do
    it "assigns the requested receipt as @receipt" do
      receipt = Receipt.create! valid_attributes
      get :show, {:id => receipt.to_param}, valid_session
      assigns(:receipt).should eq(receipt)
    end
  end

  describe "GET new" do
    it "assigns a new receipt as @receipt" do
      get :new, {}, valid_session
      assigns(:receipt).should be_a_new(Receipt)
    end
  end

  describe "GET edit" do
    it "assigns the requested receipt as @receipt" do
      receipt = Receipt.create! valid_attributes
      get :edit, {:id => receipt.to_param}, valid_session
      assigns(:receipt).should eq(receipt)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Receipt" do
        expect {
          post :create, {:receipt => valid_attributes}, valid_session
        }.to change(Receipt, :count).by(1)
      end

      it "assigns a newly created receipt as @receipt" do
        post :create, {:receipt => valid_attributes}, valid_session
        assigns(:receipt).should be_a(Receipt)
        assigns(:receipt).should be_persisted
      end

      it "redirects to the created receipt" do
        post :create, {:receipt => valid_attributes}, valid_session
        response.should redirect_to(Receipt.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved receipt as @receipt" do
        # Trigger the behavior that occurs when invalid params are submitted
        Receipt.any_instance.stub(:save).and_return(false)
        post :create, {:receipt => {  }}, valid_session
        assigns(:receipt).should be_a_new(Receipt)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Receipt.any_instance.stub(:save).and_return(false)
        post :create, {:receipt => {  }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested receipt" do
        receipt = Receipt.create! valid_attributes
        # Assuming there are no other receipts in the database, this
        # specifies that the Receipt created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Receipt.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, {:id => receipt.to_param, :receipt => { "these" => "params" }}, valid_session
      end

      it "assigns the requested receipt as @receipt" do
        receipt = Receipt.create! valid_attributes
        put :update, {:id => receipt.to_param, :receipt => valid_attributes}, valid_session
        assigns(:receipt).should eq(receipt)
      end

      it "redirects to the receipt" do
        receipt = Receipt.create! valid_attributes
        put :update, {:id => receipt.to_param, :receipt => valid_attributes}, valid_session
        response.should redirect_to(receipt)
      end
    end

    describe "with invalid params" do
      it "assigns the receipt as @receipt" do
        receipt = Receipt.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Receipt.any_instance.stub(:save).and_return(false)
        put :update, {:id => receipt.to_param, :receipt => {  }}, valid_session
        assigns(:receipt).should eq(receipt)
      end

      it "re-renders the 'edit' template" do
        receipt = Receipt.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Receipt.any_instance.stub(:save).and_return(false)
        put :update, {:id => receipt.to_param, :receipt => {  }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested receipt" do
      receipt = Receipt.create! valid_attributes
      expect {
        delete :destroy, {:id => receipt.to_param}, valid_session
      }.to change(Receipt, :count).by(-1)
    end

    it "redirects to the receipts list" do
      receipt = Receipt.create! valid_attributes
      delete :destroy, {:id => receipt.to_param}, valid_session
      response.should redirect_to(receipts_url)
    end
  end

end
