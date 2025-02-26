//
//  ClientManager.swift
//  RoboCallerMover
//
//  Created by Michelle Zheng  on 2/25/25.
//

import Supabase
import Foundation

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://trhnmlvipaujtmtvagbs.supabase.co")!,
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyaG5tbHZpcGF1anRtdHZhZ2JzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwOTM0NzUsImV4cCI6MjA1NTY2OTQ3NX0.jRvPzrjGDnm7dTdXwUEVOKspvaR7NEHzqNYR_Shhqos"
)
