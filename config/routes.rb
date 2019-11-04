Rails.application.routes.draw do
  #  resources :sheets
  #  resources :projects

  post "users/login"
  get "users/login"
  get  "users/logout"
  get "users/index"
  get "users/getone"
  post "users/index"
  post "users/new"
  post "users/update"
  post "users/delete_domaine"

  get "user_notifications/index"
  post "user_notifications/new"
  post "user_notifications/update"

  get "roles/index"
  get "roles/getone"
  post "roles/index"
  post "roles/new"
  post "roles/update"

  get "domaines/index"
  post "domaines/index"
  post "domaines/new"
  post "domaines/update"

  get "versions/index"
  get "versions/getone"
  post "versions/index"
  post "versions/new"
  post "versions/update"

  get "computers/index"
  post "computers/delete"

  get "listes/index"
  get "listes/getone"
  post "listes/index"
  post "listes/new"
  post "listes/update"

  get "kanbans/index"
  get "kanbans/parametrize"
  get "kanbans/getone"
  post "kanbans/index"
  post "kanbans/parametrize"
  post "kanbans/new"
  post "kanbans/update"

  get "type_fiches/index"
  get "type_fiches/getone"
  get "type_fiches/show"
  post "type_fiches/index"
  post "type_fiches/new"
  post "type_fiches/update"

  get "fiches/new"
  get "fiches/edit"
  get "fiches/get_fiches_filtered"
  post "fiches/update"
  post "fiches/move"
  post "fiches/uploadfile"
  post "fiches/deleteupload"

  get  "projects/index"
  get  "projects/welcome"
  post  "projects/welcome"
  get  "projects/getone"
  post  "projects/create"
  post  "projects/index"
  post  "projects/new"
  post  "projects/update"

  post  "lockobjects/delete"

  get "sheets/index"
  get "sheets/edit"
  post "sheets/index"
  post "sheets/add_sheet"
  post "sheets/add_folder"
  post "sheets/edit"
  post "sheets/update"
  post "sheets/updatediag"
  post "sheets/rename"
  post "sheets/delete"
  post "sheets/paste"
  post "sheets/holdunhold"

  get "funcandscreens/index"
  post "funcandscreens/index"
  post "funcandscreens/delete"

  get "domelements/index"
  get "domelements/update"
  post "domelements/copy"
  post "domelements/massiveinsert"
  get "domelements/proxy"

  get "procedures/index"
  get "procedures/update"
  get "procedures/edit"
  post "procedures/edit"
  get "procedures/listtoaddtotest"
  get "procedures/whocallaction"
  post "procedures/whocallaction"
  post "procedures/copy"
  get "procedures/incampain"

  get "actions/index"
  post "actions/index"
  get "actions/getone"
  get "actions/whocallaction"
  post "actions/whocallaction"
  post "actions/new"
  post "actions/update"
  post "actions/duplicate"

  get "required_gems/index"
  post "required_gems/update"

  get "tests/index"
  post "tests/index"
  get "tests/edit"
  post "tests/edit"
  post "tests/rename"
  post "tests/add_folder"
  post "tests/addtest"
  post "tests/delete"
  post "tests/update"
  post "tests/paste"
  post "tests/addsubatddfolder"
  post "tests/addatddsteptest"
  post "tests/pasteatddelement"


  post "teststeps/addnew"
  post "teststeps/addcode"
  post "teststeps/delete"
  post "teststeps/reorder"
  post "teststeps/changeparamvalue"
  post "teststeps/paste"
  post "teststeps/tododone"
  post "teststeps/validatestructure"
  post "teststeps/hold"
  post "teststeps/unhold"
  post "teststeps/changeparamatddvalue"
  post "teststeps/validarrayatdd"

  get "configuration_variables/index"
  post "configuration_variables/index"
  get "configuration_variables/getone"
  post "configuration_variables/new"
  post "configuration_variables/update"

  get "environnement_variables/index"
  get "environnement_variables/getone"
  post "environnement_variables/index"
  get "environnement_variables/update"

  get "environnements/index"
  post "environnements/index"
  get "environnements/update"

  get "data_set_variables/index"
  get "data_set_variables/getone"
  post "data_set_variables/index"
  get "data_set_variables/update"

  get "data_sets/index"
  post "data_sets/index"
  get "data_sets/update"

  get "appium_caps/index"
  post "appium_caps/index"
  get "appium_caps/update"

  get "appium_cap_values/index"
  post "appium_cap_values/index"
  get "appium_cap_values/getone"
  get "appium_cap_values/update"

  get "test_constantes/index"
  post "test_constantes/index"
  get "test_constantes/update"

  get  "node_forced_configs/index"
  post  "node_forced_configs/update"

  get  "default_user_configs/index"
  post  "default_user_configs/update"

  get  "releases/index"
  get  "releases/getone"
  post  "releases/new"
  post  "releases/update"
  post  "cycles/new"
  post  "cycles/update"

  get  "campains/index"
  post  "campains/index"
  get  "campains/edit"
  post  "campains/edit"
  get  "campains/cover"
  post  "campains/cover"
  get  "campains/wscampainresults"
  post  "campains/new"
  post  "campains/update"
  post  "campains/paste"
  post  "campains/submit"
  post  "campains/wslaunch"

  post "campain_test_suites/addnew"
  post "campain_test_suites/delete"
  post "campain_test_suites/reorder"
  post "campain_test_suites/paste"

  get  "campain_test_suite_forced_configs/index"
  post "campain_test_suite_forced_configs/update"

  get  "runs/index"
  post  "runs/index"
  post  "runs/delete"
  post  "runs/stop"
  post  "runs/unlock"

  get  "run_configs/testindex"
  post "run_configs/testupdate"

  get  "run_step_results/index"
  post  "run_step_results/index"
  get  "run_step_results/comment"
  post  "run_step_results/comment"
  post  "run_step_results/force"
  post  "run_step_results/setrefscreenshot"

  get "run_suite_schemes/index"

  get "ws/getfuncandscreens"
  get "ws/getdomelements"
  get "ws/getactions"
  get "ws/getprocedures"
  get "ws/gettests"
  get "ws/getruncode"
  get "ws/gettokenforrun"
  post "ws/postresult"
  get "ws/getrunconfigs"
  get "ws/declarecomputer"
  post "ws/undeclarecomputer"
  get "ws/isdeclaredcomputer"
  post "ws/unlocksubrun"
  get "ws/getnodestatus"
  get "ws/getsuitestatus"
  post "ws/storedata"
  get "ws/getdata"
  post "ws/uploadimage"

  get "home" => "users#login"
  get "" => "users#login"


  resources :domelements do
    member do
      delete :destroy
      post :create
      put :update
    end
  end

  resources :environnement_variables do
    member do
      delete :destroy
      post :create
      put :update
    end
  end

  resources :environnements do
    member do
      delete :destroy
      post :create
      put :update
    end
  end

  resources :data_set_variables do
    member do
      delete :destroy
      post :create
      put :update
    end
  end

  resources :data_sets do
    member do
      delete :destroy
      post :create
      put :update
    end
  end

  resources :appium_caps do
    member do
      delete :destroy
      post :create
      put :update
    end
  end

  resources :appium_cap_values do
    member do
      delete :destroy
      post :create
      put :update
    end
  end

  resources :test_constantes do
    member do
      delete :destroy
      post :create
      put :update
    end
  end

  resources :procedures do
    member do
      delete :destroy
      post :create
      put :update
    end
  end


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
