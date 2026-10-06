/**
 * Representa un producto individual dentro de un carrito de compras / pedido.
 */
export interface ProductInCart {
  id: number;
  title: string;
  price: number;
  quantity: number;
  total: number;
  discountPercentage: number;
  discountedTotal: number;
  thumbnail: string;
}

/**
 * Representa una orden o carrito de compra devuelto por la API de DummyJSON.
 */
export interface CartOrder {
  id: number;
  products: ProductInCart[];
  total: number;
  discountedTotal: number;
  userId: number;
  totalProducts: number;
  totalQuantity: number;
}

/**
 * Respuesta estructurada de la API para el endpoint GET /carts.
 */
export interface CartsApiResponse {
  carts: CartOrder[];
  total: number;
  skip: number;
  limit: number;
}
