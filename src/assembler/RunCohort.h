/*
 * This class is used to run a cohort: from input to output
 *
 */

#ifndef RUNCOHORT_H_
#define RUNCOHORT_H_

#include <iostream>
#include <vector>

using namespace std;

//local headers
#include "../CalController.h"
#include "../input/RestartInputer.h"
//#include "../input/SiteInputer.h"

#include "../output/ChtOutputer.h"
#include "../output/EnvOutputer.h"
#include "../output/BgcOutputer.h"
#include "../output/RestartOutputer.h"
#include "../output/RegnOutputer.h"

#include "../runmodule/Cohort.h"

class RunCohort {
public:
  RunCohort();
  ~RunCohort();
 
  int setup_cohort_ids(int cohort_idx);
  int setup_initcohort_ids(int cohort_idx);
  int setup_clm_ids(int cohort_idx);
  int setup_veg_ids(int cohort_idx);
  int setup_fire_ids(int cohort_idx);
  
  /* all cohort data id lists
   * ids are labeling the datasets, which exist in 5 *.nc files
   * and, the order (index, staring from 0) in these lists are actually
   * record no. in the *.nc files
   */
  vector<int> chtids; // 'cohortid.nc'
  vector<int> chtinitids;
  vector<int> chtgridids;
  vector<int> chtclmids;
  vector<int> chtvegids;
  vector<int> chtfireids;

  vector<int> chtdrainids;//from 'grid.nc' to 'cohortid.nc', related by 'GRIDID'
  vector<int> chtsoilids;
  vector<int> chtgfireids;

  vector<int> initids; // 'restart.nc' or 'sitein.nc'
  vector<int> clmids;   // 'climate.nc'
  vector<int> vegids;   // 'vegetation.nc'
  vector<int> fireids;  // 'fire.nc'

  /* the following is FOR one cohort only (current cohort)
   *
   */
  int cohortcount;
  int initrecno;
  int clmrecno;
  int vegrecno;
  int firerecno;

  int used_atmyr;
  int yrstart;
  int yrend;

  Cohort cht;

  // Output data (extracted from model's data structure)
  OutDataRegn regnod;
  RestartData resod;

  //I/O operators
  RestartInputer resinputer;
  //SiteInputer *sinputer;

  ChtOutputer dimmlyouter;
  ChtOutputer dimylyouter;

  EnvOutputer envdlyouter;
  EnvOutputer envmlyouter;
  EnvOutputer envylyouter;

  BgcOutputer bgcmlyouter;
  BgcOutputer bgcylyouter;

  RegnOutputer regnouter;
  RestartOutputer resouter;

  void setModelData(ModelData * mdp);
  int allchtids();

  void init();
  int readData();
  int reinit();

  void choose_run_stage_settings();

  void advance_one_month();
  bool get_calMode();
  void set_calMode(bool new_value);

  void output_caljson_yearly(int year);
  void output_caljson_monthly(int year, int month);

private :

  bool calMode;

  ModelData *md;

  int dstepcnt;   //day timesteps since starting output
  int mstepcnt;   //month timesteps since starting output
  int ystepcnt;   //year timesteps since starting output

  void env_only_warmup(boost::shared_ptr<CalController> calcontroller_ptr);
  void run_timeseries(boost::shared_ptr<CalController> calcontroller_ptr);
  void write_monthly_outputs(int year_idx, int month_idx);


};
#endif /*RUNCOHORT_H_*/
