#include <iostream>
#include <sqlite3.h>
#include <string>
#include <vector>
#include <ctime>
#include <iomanip>
#include <sstream>

#include <TChain.h>
#include <TFile.h>
#include <TString.h>

void queryDatabase(sqlite3* db, const std::string filename, TChain* minerva_tree, int &start_time_unix, int &end_time_unix ) {

    std::string sql = "SELECT run, subrun, start_time_unix, end_time_unix FROM CRS_summary WHERE filename ='" +
                      filename + "' LIMIT 1;";
    sqlite3_stmt* stmt;
    if (sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr) == SQLITE_OK) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            int crs_run = sqlite3_column_int(stmt, 0);
            int crs_subrun = sqlite3_column_int(stmt, 1);
            start_time_unix = sqlite3_column_int(stmt, 2);
            end_time_unix = sqlite3_column_int(stmt, 3);
            sqlite3_finalize(stmt);
            
            std::cout << "Found CRS Run: " << crs_run << ", Subrun: " << crs_subrun << std::endl;
            
            // Query Global_subrun_info
            sql = "SELECT DISTINCT mx2_run, mx2_subrun FROM All_global_subruns WHERE crs_run = " +
                  std::to_string(crs_run) + " AND crs_subrun = " + std::to_string(crs_subrun) + ";";
            std:cout<<sql<<std::endl;
            if (sqlite3_prepare_v2(db, sql.c_str(), -1, &stmt, nullptr) == SQLITE_OK) {
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    int mx2_run = sqlite3_column_int(stmt, 0);
                    int mx2_subrun = sqlite3_column_int(stmt, 1);
                    // std::cout << "MX2 Run: " << mx2_run << ", Subrun: " << mx2_subrun << std::endl;
                    std::cout << Form("/global/cfs/cdirs/dune/www/data/2x2/Mx2/dst/TS1_000%i_%04i_numib_v09*",mx2_run,mx2_subrun) <<std::endl;
                    std::cout<<start_time_unix<<" "<<end_time_unix<<std::endl;
                    minerva_tree->Add(Form("/global/cfs/cdirs/dune/www/data/2x2/Mx2/dst/TS1_000%i_%04i_numib_v09*",mx2_run,mx2_subrun));
                }
            }
            else{
                std::cout<<sql<<" "<<sqlite3_errmsg(db)<<std::endl;
            }
        }
        else{
            std::cout<<stmt<<" "<<sqlite3_errmsg(db)<<std::endl;
        }
    }
    else{
        std::cout<<sql<<" "<<sqlite3_errmsg(db)<<std::endl;
    }
    sqlite3_finalize(stmt);
}


void split_mnv(TChain *minerva_tree, int start, int end, std::string tmpdir)
{
    TString selection = Form("ev_gps_time_sec  >=%d && ev_gps_time_sec  <=%d",start, end);
    int n_val2 = minerva_tree->Draw("Entry$",selection);
    double * entry_val = minerva_tree->GetVal(0);


    TFile * my_file = TFile::Open(Form("%s/minerva_%d_%d.root",tmpdir.c_str(),start,end),
                                  "RECREATE");
    TTree * new_tree = minerva_tree->CloneTree(0);
    for (int entry_val2 =  0; entry_val2 < n_val2; entry_val2++)
    {
        minerva_tree->GetEntry(entry_val[entry_val2]);
        new_tree->Fill();
    }
    new_tree->AutoSave();
    new_tree->Write();
}

int match_minerva(std::string filename, std::string tmpdir) {
    sqlite3* db;
    if (sqlite3_open("mx2x2runs_v0.2.sqlite", &db)) {
        std::cerr << "Can't open database: " << sqlite3_errmsg(db) << std::endl;
        return 1;
    }

    TChain * minerva_tree;
    minerva_tree = new TChain("minerva");
    int start_time_unix, end_time_unix;
    queryDatabase(db, filename, minerva_tree,start_time_unix, end_time_unix);
    
    sqlite3_close(db);

    split_mnv(minerva_tree, start_time_unix, end_time_unix, tmpdir);



    return 0;
}
