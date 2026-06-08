export '../../core/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class ApiService {
  static const String BASE_URL = 'https://dashflow-backend.vercel.app/api';

  late Dio _dio;
  late SharedPreferences _prefs;

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }
  
  Dio get dio => _dio;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: BASE_URL,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: false, // Turned off to prevent flooding the terminal with JSON data
        requestHeader: true,
        error: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InByaXRhbUBkaWZtby5jb20iLCJzdWIiOiI0YmFjYzczMy1mNTY4LTRmODUtODE1Yy1mMTM2MTU0MWJhMmIiLCJjb21wYW55SWQiOiIxZTk2NDk5ZS1jMTY2LTQyMzQtOTNhNC0yOTA0OWY0NWQyOGUiLCJyb2xlcyI6W3siaWQiOiIyOGFjMWUwNS00YmRlLTQ5MjEtYTAyYS1jN2MzOWE4NDgxODMiLCJuYW1lIjoiQURNSU4iLCJkZXNjcmlwdGlvbiI6IlN1cGVyIEFkbWluIiwicGVybWlzc2lvbnMiOlt7ImlkIjoiYmIzNzZhMGItNjQ5OC00MGE3LTg1MDMtYTI5YzVmM2M2YTA4IiwiYWN0aW9uIjoiY3JlYXRlIiwicmVzb3VyY2UiOiJhdHRlbmRhbmNlIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiJmOGJhZDkyZC1jYTVjLTQzYzYtOGRmZi02ODA5ODcwNjk5ZmIiLCJhY3Rpb24iOiJjcmVhdGUiLCJyZXNvdXJjZSI6InJvbGUiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6Ijc1MDJhZmIxLWVkMGUtNGE1ZC04MDBkLWRmMGY3MWZjODQzNCIsImFjdGlvbiI6InJlYWQiLCJyZXNvdXJjZSI6InJvbGUiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6ImIxNjIwOTIyLTZmZWYtNDZlNy04NzE2LTZkNjY2ZWEwZmEyNCIsImFjdGlvbiI6InVwZGF0ZSIsInJlc291cmNlIjoicm9sZSIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiMGM4MjU1NTUtN2EyYy00MjQ1LWIxMDEtZGNkNGMwYjJiY2Q4IiwiYWN0aW9uIjoiZGVsZXRlIiwicmVzb3VyY2UiOiJyb2xlIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiI2MWY2Y2NhMy1jYzMyLTRiMTQtOWEyNy1hMTg3Y2M1OWU4MzciLCJhY3Rpb24iOiJtYW5hZ2UiLCJyZXNvdXJjZSI6InJvbGUiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6ImZkNThlNzczLTdhZTUtNDYzYy04YTcwLTJkNmRiNjEwYTY5OCIsImFjdGlvbiI6ImNyZWF0ZSIsInJlc291cmNlIjoicGVybWlzc2lvbiIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiOTMwMTM5NmQtNmExYy00YjY2LWE0OTAtYWU3NDUyN2I0MzI3IiwiYWN0aW9uIjoicmVhZCIsInJlc291cmNlIjoicGVybWlzc2lvbiIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiZjVhYzMxOWYtZjhhMC00OTZhLWI3YTUtYjY4NTY5NjczYzUwIiwiYWN0aW9uIjoidXBkYXRlIiwicmVzb3VyY2UiOiJwZXJtaXNzaW9uIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiIzNGM0OTUzYi1lZjNhLTQwYzktODU2OS1kY2MzMmQwNDAyYzgiLCJhY3Rpb24iOiJkZWxldGUiLCJyZXNvdXJjZSI6InBlcm1pc3Npb24iLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6ImI1MTk4NWJiLWQ1MGYtNGZjMi1iMjliLTE3NDM4NmI2MTg4NyIsImFjdGlvbiI6Im1hbmFnZSIsInJlc291cmNlIjoicGVybWlzc2lvbiIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiNzc3ZDRlY2EtY2ZjZS00ZDgxLWE0MWItNDI1MjYwODg5Y2Y5IiwiYWN0aW9uIjoiY3JlYXRlIiwicmVzb3VyY2UiOiJlbXBsb3llZSIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiM2U0NDYwZGMtMDNkNy00YjQ5LTg3ZGUtNzAxNjk3ODgzMGM5IiwiYWN0aW9uIjoicmVhZCIsInJlc291cmNlIjoiZW1wbG95ZWUiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6IjQ1NzUyOWI2LTkzYTctNDRmMS04YjNmLWZmMzA0ODEzY2ZmMiIsImFjdGlvbiI6InVwZGF0ZSIsInJlc291cmNlIjoiZW1wbG95ZWUiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6IjJmM2NlOTQzLTUwMWItNGFjYy05NDUxLTYxYjYyOGRhNWNiMyIsImFjdGlvbiI6ImRlbGV0ZSIsInJlc291cmNlIjoiZW1wbG95ZWUiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6IjhmY2ZlZDNkLWRhZjAtNDA4NC04ZWJhLWRmYTgwNzhjMzRhMiIsImFjdGlvbiI6Im1hbmFnZSIsInJlc291cmNlIjoiZW1wbG95ZWUiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6IjljNDNmMzc5LWI3NzgtNGY4OC04NDE1LTVjMWEyODkyZTRmOSIsImFjdGlvbiI6ImNyZWF0ZSIsInJlc291cmNlIjoicHJvamVjdCIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiYjVkMmNhOGMtOTY1Yy00NjAyLWJhYzMtY2FkNDQ4MzAxMzBjIiwiYWN0aW9uIjoicmVhZCIsInJlc291cmNlIjoicHJvamVjdCIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiZjllZDE0M2MtNGM1Ni00MWU1LTk5MGEtZmE1MzI3MjM0NGQ5IiwiYWN0aW9uIjoidXBkYXRlIiwicmVzb3VyY2UiOiJwcm9qZWN0IiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiIyZTYwNWJkNS04ZDUxLTQ5NTMtOTE4MS0zN2I3Mzk0Zjg4YjMiLCJhY3Rpb24iOiJkZWxldGUiLCJyZXNvdXJjZSI6InByb2plY3QiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6IjkxNzA2M2RlLTIxMmUtNDE3Yi04NjQyLTZlY2Y3MzVhZDdkYSIsImFjdGlvbiI6Im1hbmFnZSIsInJlc291cmNlIjoicHJvamVjdCIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiN2U2NGZlMWEtMTIyNC00NTk3LWJkNzMtZTZjNTA4OGRiMTQzIiwiYWN0aW9uIjoiY3JlYXRlIiwicmVzb3VyY2UiOiJ0YXNrIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiJiOWIzODc1My1kMDYwLTQ0OTMtYWYyYS01NzIzMGE3MzIyYTMiLCJhY3Rpb24iOiJyZWFkIiwicmVzb3VyY2UiOiJ0YXNrIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiI2ODI2ZjhlYy0wZGY0LTQ1ZDktYTU1ZS1hNjI1MWMyOTA1YzkiLCJhY3Rpb24iOiJ1cGRhdGUiLCJyZXNvdXJjZSI6InRhc2siLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6ImU2NjQ2NmYyLTIwODEtNDQ3NS04NWJmLWE4ZTM4YTc3YzI5ZCIsImFjdGlvbiI6ImRlbGV0ZSIsInJlc291cmNlIjoidGFzayIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiYmM0MzVlZDQtNDA1Zi00NGJjLTkyYWUtNTdiODdjNDk4Mjg5IiwiYWN0aW9uIjoibWFuYWdlIiwicmVzb3VyY2UiOiJ0YXNrIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiJhMDM0NjljNi0yYjQxLTQ1MGItYmFhNC0xOTFiNGEyMDIyM2QiLCJhY3Rpb24iOiJjcmVhdGUiLCJyZXNvdXJjZSI6InBheXJvbGwiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6ImEyMjA1M2VjLTczYzAtNDEwMy05ZmM4LTcyNjJhOTkyODRlNiIsImFjdGlvbiI6InJlYWQiLCJyZXNvdXJjZSI6InBheXJvbGwiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6IjYyODU0NzJlLTY1NTktNGEyOC1iODdhLTQ4ODMyNzllZmUzNCIsImFjdGlvbiI6InVwZGF0ZSIsInJlc291cmNlIjoicGF5cm9sbCIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiMGVlOGQxNTUtODU0Ny00ODQ4LTg2ODgtNjUxOWFiMmJiYjZmIiwiYWN0aW9uIjoiZGVsZXRlIiwicmVzb3VyY2UiOiJwYXlyb2xsIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiJlZGMyNWExZi0yNmVhLTQxMDQtYTc0MS00NWNmZmEyNTIyOTUiLCJhY3Rpb24iOiJtYW5hZ2UiLCJyZXNvdXJjZSI6InBheXJvbGwiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6IjZkN2M4ODkyLTUzOGUtNGFhYS1hM2JmLTAxNWVjZDQ2MzIwNyIsImFjdGlvbiI6InJlYWQiLCJyZXNvdXJjZSI6ImF0dGVuZGFuY2UiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6IjA2Y2E1ODdiLWY1YmEtNGEwYy1hZGMzLWMyOThlZGQwZDFlMiIsImFjdGlvbiI6InVwZGF0ZSIsInJlc291cmNlIjoiYXR0ZW5kYW5jZSIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiZGExOTQxMjAtOTA5ZS00MDNhLTk2YmQtMGFiMzc5ZTMxMzRkIiwiYWN0aW9uIjoiZGVsZXRlIiwicmVzb3VyY2UiOiJhdHRlbmRhbmNlIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiJmMDE3YTU1OS0zNWM3LTQ2NWItYWRmNi03ZjE1ZjYwODhkY2EiLCJhY3Rpb24iOiJtYW5hZ2UiLCJyZXNvdXJjZSI6ImF0dGVuZGFuY2UiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6ImE2YzFkMzQ0LTM1MzktNGM4ZC1iMzk1LTE3YmVjZjc0OTdhZSIsImFjdGlvbiI6ImNyZWF0ZSIsInJlc291cmNlIjoibGVhdmUiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6ImNmMWRjZmU1LTg2NWItNDQ1Zi05NjFiLTMwM2U1ZDE2MzdhZSIsImFjdGlvbiI6InJlYWQiLCJyZXNvdXJjZSI6ImxlYXZlIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiI4OTliYzZiYS0yNzdlLTRlZjItOTgyZi0zYmVlMjdhZjA2ODciLCJhY3Rpb24iOiJ1cGRhdGUiLCJyZXNvdXJjZSI6ImxlYXZlIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiI2N2Y3NTllZC1kMTMyLTRmNmUtODkyNS1iNWY0ZDIzYjMzZTUiLCJhY3Rpb24iOiJkZWxldGUiLCJyZXNvdXJjZSI6ImxlYXZlIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiI1NTAzMmVhNC1mOWJmLTRhZTEtYjQxMC03MDVmZDM0NjM3YTUiLCJhY3Rpb24iOiJtYW5hZ2UiLCJyZXNvdXJjZSI6ImxlYXZlIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiJlNmQ5MjA3ZC05OWQ3LTQzMDUtODRmOS03MGM3ZjgxYTVlZjkiLCJhY3Rpb24iOiJjcmVhdGUiLCJyZXNvdXJjZSI6ImV4cGVuc2UiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6ImRhNjA0OTk1LTcwMTAtNDE4OC04NmI5LWVhYjM1NjVkNzkyMiIsImFjdGlvbiI6InJlYWQiLCJyZXNvdXJjZSI6ImV4cGVuc2UiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6IjYxNGU1MjQwLWMwOTAtNDUwMC1hNTc2LWQ5OTk1YzBlYjdhZSIsImFjdGlvbiI6InVwZGF0ZSIsInJlc291cmNlIjoiZXhwZW5zZSIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiNzJkNTcyOGUtOTYxZS00ZDU0LWJmMWMtNWU2ZWIxNzRmZDllIiwiYWN0aW9uIjoiZGVsZXRlIiwicmVzb3VyY2UiOiJleHBlbnNlIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiJlZDRjZjIxMy03ZWM3LTQ0NDctYTM2Zi0xOGM1Zjg1MDM1OWYiLCJhY3Rpb24iOiJtYW5hZ2UiLCJyZXNvdXJjZSI6ImV4cGVuc2UiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6ImM5MWU0NTBjLThkMzctNDgxOS04ZGViLTkzODU5MTYyNDE0YSIsImFjdGlvbiI6ImNyZWF0ZSIsInJlc291cmNlIjoidXNlciIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiYmUzNDg4MzgtYTgzNC00MzMyLThkY2UtOWI4ZGU1ZDZkOWYzIiwiYWN0aW9uIjoicmVhZCIsInJlc291cmNlIjoidXNlciIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiOWU1ZGJjMjctYzliYy00Yjk1LWE4YTgtZTk4ZDE5YWU1ZWE1IiwiYWN0aW9uIjoidXBkYXRlIiwicmVzb3VyY2UiOiJ1c2VyIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiIyMDY0ZjFhYy0yMWRmLTQyNjEtOTMzZS0wZGY1Zjg2NWNjNTYiLCJhY3Rpb24iOiJkZWxldGUiLCJyZXNvdXJjZSI6InVzZXIiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6Ijk2YTU2OTZmLTliOGUtNGMxZi04NDg5LTE5OWFmZDFkMGI4ZiIsImFjdGlvbiI6Im1hbmFnZSIsInJlc291cmNlIjoidXNlciIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiZmI0MjYxZjQtYjVlNC00MDhiLWJmODktNThkMjU3NmJhYTcxIiwiYWN0aW9uIjoiY3JlYXRlIiwicmVzb3VyY2UiOiJpbnRlcm4iLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6IjJlM2YwZDI1LWUwYTItNGU1Ni1iZjU0LWNiYzEzY2M4MmI2OCIsImFjdGlvbiI6InJlYWQiLCJyZXNvdXJjZSI6ImludGVybiIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiMmI1NjJlMDEtMDI4Yi00NzVlLWIzMzMtY2UyOWJmYzRjOGM5IiwiYWN0aW9uIjoidXBkYXRlIiwicmVzb3VyY2UiOiJpbnRlcm4iLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6IjhhNjBiZDJiLWRlOGItNDNkZC04NGZiLTlkNDg4NWM0MjRlZCIsImFjdGlvbiI6ImRlbGV0ZSIsInJlc291cmNlIjoiaW50ZXJuIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiI0NDk2YjExOC1jOWY0LTQzMWYtOTRiZi1kZGVkM2E3ZDZjYjgiLCJhY3Rpb24iOiJtYW5hZ2UiLCJyZXNvdXJjZSI6ImludGVybiIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiOTQ1MjI4NjgtODkwOC00NTk1LTg4MDYtNTFjNjZlYjUwYTA4IiwiYWN0aW9uIjoiY3JlYXRlIiwicmVzb3VyY2UiOiJub3RpZmljYXRpb24iLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6IjdiZTBhN2Q1LTQwMGEtNGUxNy1hZDlkLWY1NzMwZjE0ZTU4OCIsImFjdGlvbiI6InJlYWQiLCJyZXNvdXJjZSI6Im5vdGlmaWNhdGlvbiIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiMzkzNjE0NzMtOTlkYS00YzFhLWIxNDYtNzNlZjdjYThlMTBjIiwiYWN0aW9uIjoidXBkYXRlIiwicmVzb3VyY2UiOiJub3RpZmljYXRpb24iLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6Ijg2NzU5ZTc0LTkxZDktNDU1ZC05ZGIwLWEwYjQzNTM3OWVkMSIsImFjdGlvbiI6ImRlbGV0ZSIsInJlc291cmNlIjoibm90aWZpY2F0aW9uIiwiZGVzY3JpcHRpb24iOm51bGwsImNvbmRpdGlvbnMiOm51bGx9LHsiaWQiOiJkZTYyMjQ4OS1mNzBhLTQ3ZDQtOTE1NC05MGQxNDIxNGU0MzQiLCJhY3Rpb24iOiJtYW5hZ2UiLCJyZXNvdXJjZSI6Im5vdGlmaWNhdGlvbiIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfV19LHsiaWQiOiJkZTUwZTc5MS04ODc1LTRjODUtODgwZC0zNjIzNzFhNWM3MDMiLCJuYW1lIjoiRW1wbG95ZWUiLCJkZXNjcmlwdGlvbiI6ImFjY29yZGluZyB0byB0aGUgcm9sZSIsInBlcm1pc3Npb25zIjpbeyJpZCI6ImI5YjM4NzUzLWQwNjAtNDQ5My1hZjJhLTU3MjMwYTczMjJhMyIsImFjdGlvbiI6InJlYWQiLCJyZXNvdXJjZSI6InRhc2siLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6ImI1ZDJjYThjLTk2NWMtNDYwMi1iYWMzLWNhZDQ0ODMwMTMwYyIsImFjdGlvbiI6InJlYWQiLCJyZXNvdXJjZSI6InByb2plY3QiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6ImEyMjA1M2VjLTczYzAtNDEwMy05ZmM4LTcyNjJhOTkyODRlNiIsImFjdGlvbiI6InJlYWQiLCJyZXNvdXJjZSI6InBheXJvbGwiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH0seyJpZCI6ImJiMzc2YTBiLTY0OTgtNDBhNy04NTAzLWEyOWM1ZjNjNmEwOCIsImFjdGlvbiI6ImNyZWF0ZSIsInJlc291cmNlIjoiYXR0ZW5kYW5jZSIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiNmQ3Yzg4OTItNTM4ZS00YWFhLWEzYmYtMDE1ZWNkNDYzMjA3IiwiYWN0aW9uIjoicmVhZCIsInJlc291cmNlIjoiYXR0ZW5kYW5jZSIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiYTZjMWQzNDQtMzUzOS00YzhkLWIzOTUtMTdiZWNmNzQ5N2FlIiwiYWN0aW9uIjoiY3JlYXRlIiwicmVzb3VyY2UiOiJsZWF2ZSIsImRlc2NyaXB0aW9uIjpudWxsLCJjb25kaXRpb25zIjpudWxsfSx7ImlkIjoiY2YxZGNmZTUtODY1Yi00NDVmLTk2MWItMzAzZTVkMTYzN2FlIiwiYWN0aW9uIjoicmVhZCIsInJlc291cmNlIjoibGVhdmUiLCJkZXNjcmlwdGlvbiI6bnVsbCwiY29uZGl0aW9ucyI6bnVsbH1dfV0sImxvZ2luUm9sZSI6ImFkbWluIiwiaWF0IjoxNzgwOTE3ODgzLCJleHAiOjE3ODE1MjI2ODN9.v_lEXYdV88JCLEOqqzNx4Xj9VVy0wpjq1qrbNYkIbnc";
          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      var inner = responseData['data'];
      if (inner is Map<String, dynamic> && inner.containsKey('data')) {
        return inner['data'];
      }
      return inner;
    }
    return responseData;
  }

  // ─────────────────────────── AUTH ───────────────────────────

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token =
            data['data']?['access_token'] ??
            data['access_token'] ??
            data['token'];
        if (token != null) {
          await saveToken(token);
        }
        return response.data;
      }
      throw Exception('Login failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login error');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to fetch profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching profile');
    }
  }

  Future<Map<String, dynamic>> switchCompany(String companyId) async {
    try {
      final response = await _dio.post(
        '/auth/switch-company',
        data: {'companyId': companyId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['access_token'] ?? response.data['token'];
        if (token != null) {
          await saveToken(token);
        }
        return response.data;
      }
      throw Exception('Failed to switch company');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error switching company');
    }
  }

  Future<List<dynamic>> getMyWorkspaces() async {
    try {
      final response = await _dio.get('/auth/my-workspaces');
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch workspaces');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching workspaces',
      );
    }
  }

  Future<Map<String, dynamic>> changePassword(String newPassword) async {
    try {
      final response = await _dio.patch(
        '/auth/change-password',
        data: {'newPassword': newPassword},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to change password');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error changing password');
    }
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password/send-otp',
        data: {'email': email},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to send OTP');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error sending OTP');
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password/reset',
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to reset password');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error resetting password',
      );
    }
  }

  // ─────────────────────────── USERS ───────────────────────────

  Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await _dio.get('/users');
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch users');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching users');
    }
  }

  Future<List<dynamic>> getDashboard() async {
    try {
      final response = await _dio.get('/dashboard/metrics');
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch users');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching users');
    }
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch user');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching user');
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
    String? companyId,
  }) async {
    try {
      final response = await _dio.post(
        '/users',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'role': role,
          if (companyId != null) 'companyId': companyId,
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create user');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating user');
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await _dio.put(
        '/users/$userId',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'role': role,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update user');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating user');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await _dio.delete('/users/$userId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete user');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting user');
    }
  }

  // ─────────────────────────── EMPLOYEES ───────────────────────────

  Future<Map<String, dynamic>> createEmployee({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String designation,
    required String department,
    String? password,
  }) async {
    try {
      final response = await _dio.post(
        '/employees',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'designation': designation,
          'department': department,
          if (password != null && password.isNotEmpty) 'password': password,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create employee');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating employee');
    }
  }

  Future<List<dynamic>> getAllEmployees({
    String? department,
    String? branch,
    String? employmentType,
    String? status,
    String? companyId,
  }) async {
    try {
      final response = await _dio.get(
        '/employees',
        queryParameters: {
          if (department != null) 'department': department,
          if (branch != null) 'branch': branch,
          if (employmentType != null) 'employmentType': employmentType,
          if (status != null) 'status': status,
          if (companyId != null) 'companyId': companyId,
        },
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch employees');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching employees');
    }
  }

  Future<Map<String, dynamic>> getEmployeeById(String id) async {
    try {
      final response = await _dio.get('/employees/$id');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch employee');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching employee');
    }
  }

  Future<Map<String, dynamic>> updateEmployee({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String designation,
    required String department,
    String? password,
  }) async {
    try {
      final response = await _dio.put(
        '/employees/$id',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'designation': designation,
          'department': department,
          if (password != null && password.isNotEmpty) 'password': password,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update employee');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating employee');
    }
  }

  Future<Map<String, dynamic>> updateEmployeeStatus(
    String id,
    String status,
  ) async {
    try {
      final response = await _dio.patch(
        '/employees/$id/status',
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update employee status');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error updating employee status',
      );
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      final response = await _dio.delete('/employees/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete employee');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting employee');
    }
  }

  Future<Map<String, dynamic>> syncEmployeeRoles(String companyId) async {
    try {
      final response = await _dio.post(
        '/employees/sync-roles',
        data: {'companyId': companyId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to sync employee roles');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error syncing employee roles',
      );
    }
  }

  Future<Map<String, dynamic>> assignBulkManagers(
    List<String> employeeIds,
  ) async {
    try {
      final response = await _dio.post(
        '/employees/bulk-managers',
        data: {'employeeIds': employeeIds},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to assign managers in bulk');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error assigning bulk managers',
      );
    }
  }

  Future<void> revokeManagerRole(String id) async {
    try {
      final response = await _dio.delete('/employees/$id/manager-role');
      if (response.statusCode != 200) {
        throw Exception('Failed to revoke manager role');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error revoking manager role',
      );
    }
  }

  Future<Map<String, dynamic>> getEmployeeCount(String companyId) async {
    try {
      final response = await _dio.get(
        '/employees/stats/count',
        queryParameters: {'companyId': companyId},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch employee count');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching employee count',
      );
    }
  }

  // ─────────────────────────── COMPANIES ───────────────────────────

  Future<List<dynamic>> getAllCompanies() async {
    try {
      final response = await _dio.get('/companies');
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch companies');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching companies',
      );
    }
  }

  Future<Map<String, dynamic>> getCompanyById(String companyId) async {
    try {
      final response = await _dio.get('/companies/$companyId');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch company');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching company');
    }
  }

  Future<Map<String, dynamic>> createCompany({
    required String name,
    required String email,
    required String website,
    required String industry,
    required int size,
    required String address,
    required String city,
    required String country,
  }) async {
    try {
      final response = await _dio.post(
        '/companies',
        data: {
          'name': name,
          'email': email,
          'website': website,
          'industry': industry,
          'size': size,
          'address': address,
          'city': city,
          'country': country,
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create company');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating company');
    }
  }

  Future<Map<String, dynamic>> updateCompany({
    required String companyId,
    required String name,
    required String email,
    required String website,
    required String industry,
    required int size,
    required String address,
    required String city,
    required String country,
  }) async {
    try {
      final response = await _dio.put(
        '/companies/$companyId',
        data: {
          'name': name,
          'email': email,
          'website': website,
          'industry': industry,
          'size': size,
          'address': address,
          'city': city,
          'country': country,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update company');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating company');
    }
  }

  Future<void> deleteCompany(String companyId) async {
    try {
      final response = await _dio.delete('/companies/$companyId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete company');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting company');
    }
  }

  Future<Map<String, dynamic>> getCompanyGst(String id) async {
    try {
      final response = await _dio.get('/companies/$id');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch GST info');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching GST info');
    }
  }

  Future<Map<String, dynamic>> updateCompanyGst(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch('/companies/$id', data: data);
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update GST info');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating GST info');
    }
  }

  // ─────────────────────────── LEAVES ───────────────────────────

  Future<List<dynamic>> getAllLeaves({
    String? companyId,
    String? employeeId,
    String? status,
    String? type,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (companyId != null) queryParams['companyId'] = companyId;
      if (employeeId != null) queryParams['employeeId'] = employeeId;
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;

      final response = await _dio.get('/leaves', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch leaves');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching leaves');
    }
  }

  Future<Map<String, dynamic>> getLeaveById(String leaveId) async {
    try {
      final response = await _dio.get('/leaves/$leaveId');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch leave');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching leave');
    }
  }

  Future<Map<String, dynamic>> requestLeave({
    required String employeeId,
    required String startDate,
    required String endDate,
    required String type,
    String? reason,
    String? companyId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'employeeId': employeeId,
        'startDate': startDate,
        'endDate': endDate,
        'type': type,
      };
      if (reason != null && reason.isNotEmpty) data['reason'] = reason;
      if (companyId != null && companyId.isNotEmpty) data['companyId'] = companyId;

      final response = await _dio.post(
        '/leaves',
        data: data,
      );
      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to request leave');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error requesting leave');
    }
  }

  Future<Map<String, dynamic>> updateLeaveStatus({
    required String leaveId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final response = await _dio.patch(
        '/leaves/$leaveId/status',
        data: {
          'status': status,
          if (rejectionReason != null) 'rejectionReason': rejectionReason,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update leave status');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating leave');
    }
  }

  Future<Map<String, dynamic>> updateLeaveDetails({
    required String leaveId,
    String? startDate,
    String? endDate,
    String? type,
  }) async {
    try {
      final response = await _dio.patch(
        '/leaves/$leaveId',
        data: {
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          if (type != null) 'type': type,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update leave details');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error updating leave details',
      );
    }
  }

  Future<void> deleteLeave(String leaveId) async {
    try {
      final response = await _dio.delete('/leaves/$leaveId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete leave');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting leave');
    }
  }

  // ─────────────────────────── WFH REQUESTS ───────────────────────────

  Future<List<dynamic>> getWfhRequests({
    String? companyId,
    String? employeeId,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (companyId != null) queryParams['companyId'] = companyId;
      if (employeeId != null) queryParams['employeeId'] = employeeId;
      if (status != null) queryParams['status'] = status;
      final response = await _dio.get(
        '/wfh-requests',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch WFH requests');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching WFH requests',
      );
    }
  }

  Future<Map<String, dynamic>> getWfhRequestById(String id) async {
    try {
      final response = await _dio.get('/wfh-requests/$id');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch WFH request');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching WFH request',
      );
    }
  }

  Future<Map<String, dynamic>> submitWfhRequest({
    required String employeeId,
    required String companyId,
    required String date,
    required String reason,
  }) async {
    try {
      final response = await _dio.post(
        '/wfh-requests',
        data: {
          'employeeId': employeeId,
          'companyId': companyId,
          'date': date,
          'reason': reason,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to submit WFH request');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error submitting WFH request',
      );
    }
  }

  Future<Map<String, dynamic>> updateWfhRequestStatus({
    required String id,
    required String status,
    String? comment,
  }) async {
    try {
      final response = await _dio.patch(
        '/wfh-requests/$id/status',
        data: {
          'status': status,
          if (comment != null) 'comment': comment,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update WFH request status');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error updating WFH request',
      );
    }
  }

  Future<void> deleteWfhRequest(String id) async {
    try {
      final response = await _dio.delete('/wfh-requests/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete WFH request');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error deleting WFH request',
      );
    }
  }

  // ─────────────────────────── ATTENDANCE ───────────────────────────

  Future<Map<String, dynamic>> getAttendanceAnalytics({
    required String companyId,
    required int month,
    required int year,
  }) async {
    try {
      final response = await _dio.get(
        '/attendance/analytics',
        queryParameters: {'companyId': companyId, 'month': month, 'year': year},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch attendance analytics');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching attendance analytics',
      );
    }
  }

  // ─────────────────────────── DEPARTMENTS ───────────────────────────

  Future<List<dynamic>> getDepartments(String companyId) async {
    try {
      final response = await _dio.get(
        '/departments',
        queryParameters: {'companyId': companyId},
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch departments');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching departments',
      );
    }
  }

  Future<Map<String, dynamic>> createDepartment({
    required String name,
    required String companyId,
  }) async {
    try {
      final response = await _dio.post(
        '/departments',
        data: {'name': name, 'companyId': companyId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create department');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error creating department',
      );
    }
  }

  Future<void> deleteDepartment(String id) async {
    try {
      final response = await _dio.delete('/departments/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete department');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error deleting department',
      );
    }
  }

  // ─────────────────────────── DESIGNATIONS ───────────────────────────

  Future<List<dynamic>> getDesignations(String companyId) async {
    try {
      final response = await _dio.get(
        '/designations',
        queryParameters: {'companyId': companyId},
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch designations');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching designations',
      );
    }
  }

  Future<Map<String, dynamic>> createDesignation({
    required String name,
    required String companyId,
  }) async {
    try {
      final response = await _dio.post(
        '/designations',
        data: {'name': name, 'companyId': companyId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create designation');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error creating designation',
      );
    }
  }

  Future<void> deleteDesignation(String id) async {
    try {
      final response = await _dio.delete('/designations/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete designation');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error deleting designation',
      );
    }
  }

  // ─────────────────────────── FINANCE / PAYROLL ───────────────────────────

  Future<Map<String, dynamic>> createPayroll({
    required String employeeId,
    required int month,
    required int year,
    required double basicSalary,
    required double allowances,
    required double deductions,
    required double netSalary,
  }) async {
    try {
      final response = await _dio.post(
        '/finance/payroll',
        data: {
          'employeeId': employeeId,
          'month': month,
          'year': year,
          'basicSalary': basicSalary,
          'allowances': allowances,
          'deductions': deductions,
          'netSalary': netSalary,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create payroll');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating payroll');
    }
  }

  Future<List<dynamic>> getPayrolls({
    String? employeeId,
    String? companyId,
    int? month,
    int? year,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (employeeId != null) queryParams['employeeId'] = employeeId;
      if (companyId != null) queryParams['companyId'] = companyId;
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _dio.get(
        '/finance/payroll',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch payrolls');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching payrolls');
    }
  }

  Future<Map<String, dynamic>> updatePayroll(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch('/finance/payroll/$id', data: data);
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update payroll');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating payroll');
    }
  }

  Future<void> deletePayroll(String id) async {
    try {
      final response = await _dio.delete('/finance/payroll/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete payroll');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting payroll');
    }
  }

  Future<Map<String, dynamic>> markPayrollPaid(String payrollId) async {
    try {
      final response = await _dio.post(
        '/finance/payroll/pay',
        data: {'payrollId': payrollId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to mark payroll as paid');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error marking payroll as paid',
      );
    }
  }

  Future<dynamic> downloadPayrollSlip(String id) async {
    try {
      final response = await _dio.get('/finance/payroll/$id/slip');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to download slip');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error downloading slip');
    }
  }

  Future<void> sendPayrollEmail({
    required String id,
    String? customHtml,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/finance/payroll/$id/send-email',
        data: {
          if (customHtml != null) 'customHtml': customHtml,
          if (notes != null) 'notes': notes,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send email');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error sending email');
    }
  }

  Future<Map<String, dynamic>> generatePayroll({
    required String attendanceId,
    required int month,
    required int year,
  }) async {
    try {
      final response = await _dio.post(
        '/finance/generate',
        data: {'attendanceId': attendanceId, 'month': month, 'year': year},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to generate payroll');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error generating payroll',
      );
    }
  }

  Future<Map<String, dynamic>> generateSinglePayroll(
    String attendanceId,
  ) async {
    try {
      final response = await _dio.post(
        '/finance/generate-single',
        data: {'attendanceId': attendanceId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to generate single payroll');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error generating single payroll',
      );
    }
  }

  // ─────────────────────────── FINANCE / EXPENSES ───────────────────────────

  Future<Map<String, dynamic>> createExpense({
    required String companyId,
    required String title,
    required double amount,
    required String currency,
    required String category,
    required String date,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '/finance/expenses',
        data: {
          'companyId': companyId,
          'title': title,
          'amount': amount,
          'currency': currency,
          'category': category,
          'date': date,
          'description': description,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create expense');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating expense');
    }
  }

  Future<List<dynamic>> getExpenses({
    String? companyId,
    String? currency,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (companyId != null) queryParams['companyId'] = companyId;
      if (currency != null) queryParams['currency'] = currency;

      final response = await _dio.get(
        '/finance/expenses',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch expenses');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching expenses');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final response = await _dio.delete('/finance/expenses/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete expense');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting expense');
    }
  }

  Future<Map<String, dynamic>> getFinanceSummary({
    String? companyId,
    int? month,
    int? year,
    String? currency,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (companyId != null) queryParams['companyId'] = companyId;
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;
      if (currency != null) queryParams['currency'] = currency;

      final response = await _dio.get(
        '/finance/summary',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch finance summary');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching finance summary',
      );
    }
  }

  // ─────────────────────────── PROJECTS ───────────────────────────

  Future<List<dynamic>> getProjects(String companyId) async {
    try {
      final response = await _dio.get(
        '/projects',
        queryParameters: {'companyId': companyId},
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch projects');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching projects');
    }
  }

  Future<Map<String, dynamic>> createProject({
    required String name,
    required String description,
    required String companyId,
    required String startDate,
    required String endDate,
    String? clientId,
    int? budget,
    List<String>? memberIds,
  }) async {
    try {
      final response = await _dio.post(
        '/projects',
        data: {
          'name': name,
          'description': description,
          'companyId': companyId,
          'startDate': startDate,
          'endDate': endDate,
          if (clientId != null) 'clientId': clientId,
          if (budget != null) 'budget': budget,
          if (memberIds != null) 'memberIds': memberIds,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create project');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating project');
    }
  }

  // ─────────────────────────── CLIENTS ───────────────────────────

  Future<List<dynamic>> getClients() async {
    try {
      final response = await _dio.get('/clients');
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch clients');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching clients');
    }
  }

  Future<Map<String, dynamic>> createClient({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String companyId,
  }) async {
    try {
      final response = await _dio.post(
        '/clients',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'companyId': companyId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create client');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating client');
    }
  }

  // ─────────────────────────── TIME TRACKING ───────────────────────────

  Future<Map<String, dynamic>> startTimeTracking({
    required String employeeId,
    required String taskId,
    required String projectId,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '/time-tracking/start',
        data: {
          'employeeId': employeeId,
          'taskId': taskId,
          'projectId': projectId,
          'description': description,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to start timer');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error starting timer');
    }
  }

  Future<Map<String, dynamic>> stopTimeTracking(
    String id,
    String description,
  ) async {
    try {
      final response = await _dio.put(
        '/time-tracking/stop/$id',
        data: {'description': description},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to stop timer');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error stopping timer');
    }
  }

  Future<List<dynamic>> getTimeTrackingEntries(String employeeId) async {
    try {
      final response = await _dio.get(
        '/time-tracking',
        queryParameters: {'employeeId': employeeId},
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch time entries');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching time entries',
      );
    }
  }

  // ─────────────────────────── NOTIFICATIONS ───────────────────────────

  Future<void> registerFcmToken({
    required String token,
    required String platform,
    required String deviceId,
  }) async {
    try {
      final response = await _dio.post(
        '/notifications/fcm-token',
        data: {'token': token, 'platform': platform, 'deviceId': deviceId},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to register FCM token');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error registering FCM token',
      );
    }
  }

  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications/mine');
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch notifications');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching notifications',
      );
    }
  }

  // ─────────────────────────── DASHBOARD ───────────────────────────

  Future<Map<String, dynamic>> getDashboardMetrics({
    required String companyId,
    String? userId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'companyId': companyId};
      if (userId != null) queryParams['userId'] = userId;
      final response = await _dio.get(
        '/dashboard/metrics',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch dashboard metrics');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching dashboard metrics',
      );
    }
  }

  Future<Map<String, dynamic>> getDashboardCharts(String companyId) async {
    try {
      final response = await _dio.get(
        '/dashboard/charts',
        queryParameters: {'companyId': companyId},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch dashboard charts');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching dashboard charts',
      );
    }
  }

  // ─────────────────────────── TOKEN HELPERS ───────────────────────────

  Future<void> saveToken(String token) async {
    await _prefs.setString('jwt_token', token);
  }

  Future<String?> getToken() async {
    return _prefs.getString('jwt_token');
  }

  Future<void> clearToken() async {
    await _prefs.remove('jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }


}