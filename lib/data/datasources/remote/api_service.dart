import 'package:dio/dio.dart';
import '../../mappers/birthday_json_mapper.dart';
import '../../models/birthday_model.dart';
import '../../models/api_response.dart';

class ApiService {
  final Dio _dio;
  final String _baseUrl = 'https://your-api-url.com/api'; // À remplacer

  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: 'https://your-api-url.com/api',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  )) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Ajouter le token d'authentification si disponible
        // options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (error, handler) {
        // Gérer les erreurs globalement
        return handler.next(error);
      },
    ));
  }

  Future<ApiResponse<List<BirthdayModel>>> getBirthdays() async {
    try {
      final response = await _dio.get('/birthdays');
      final List<BirthdayModel> birthdays = (response.data as List)
          .map((json) => BirthdayJsonMapper.fromJson(json))
          .toList();
      return ApiResponse.success(birthdays);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data?['message'] ?? 'Erreur lors de la récupération',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Erreur inconnue');
    }
  }

  Future<ApiResponse<BirthdayModel>> addBirthday(
      BirthdayModel birthday) async {
    try {
      final response = await _dio.post(
        '/birthdays',
        data: BirthdayJsonMapper.toJson(birthday), // MODIFIÉ ICI
      );
      final BirthdayModel createdBirthday =
      BirthdayJsonMapper.fromJson(response.data); // MODIFIÉ ICI
      return ApiResponse.success(createdBirthday);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data?['message'] ?? 'Erreur lors de l\'ajout',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Erreur inconnue');
    }
  }

  Future<ApiResponse<void>> updateBirthday(BirthdayModel birthday) async {
    try {
      await _dio.put(
        '/birthdays/${birthday.id}',
        data: BirthdayJsonMapper.toJson(birthday), // MODIFIÉ ICI
      );
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data?['message'] ?? 'Erreur lors de la mise à jour',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Erreur inconnue');
    }
  }

  Future<ApiResponse<void>> deleteBirthday(String id) async {
    try {
      await _dio.delete('/birthdays/$id');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data?['message'] ?? 'Erreur lors de la suppression',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Erreur inconnue');
    }
  }

  // Méthode d'authentification (optionnel)
  Future<ApiResponse<String>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final String token = response.data['token'];
      return ApiResponse.success(token);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data?['message'] ?? 'Erreur de connexion',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Erreur inconnue');
    }
  }
}