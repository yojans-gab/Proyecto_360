const conexion = require('../DBConection/db')

exports.createProduct = async (req, res) => {
  const pool = await conexion();
  const {
      CategoriaProductos_idCategoriaProductos,
      usuarios_idusuarios,
      nombre,
      marca,
      codigo,
      stock,
      estados_idestados,
      precio,
      foto,
  } = req.body;

  const { idusuarios, rol_idrol } = req.user; // Datos del usuario autenticado

  try {
      // Verificar si el usuario tiene rol operador
      const [rol] = await pool.query(
          `SELECT nombre 
           FROM rol 
           WHERE idrol = :rol_idrol`,
          { replacements: { rol_idrol } }
      );

      if (!rol || rol[0].nombre.toLowerCase() !== 'Operador') {
          return res.status(403).json({ msg: 'No tiene permiso para insertar productos' });
      }

      // Insertar producto
      await pool.query(
          `EXEC p_InsertarProducto 
              @CategoriaProductos_idCategoriaProductos = :CategoriaProductos_idCategoriaProductos, 
              @usuarios_idusuarios = :idusuarios, 
              @nombre = :nombre, 
              @marca = :marca, 
              @codigo = :codigo, 
              @stock = :stock, 
              @estados_idestados = :estados_idestados, 
              @precio = :precio, 
              @foto = :foto`,
          {
              replacements: {
                  CategoriaProductos_idCategoriaProductos,
                  idusuarios, // Asignar automáticamente el usuario autenticado
                  nombre,
                  marca,
                  codigo,
                  stock,
                  estados_idestados,
                  precio,
                  foto,
              },
          }
      );

      res.json({ msg: 'Producto insertado correctamente' });
  } catch (error) {
      console.error('Error al insertar producto:', error);
      res.status(500).json({ msg: 'Error al insertar producto' });
  }
};


exports.getProducts = async (req, res) => {
  const pool = await conexion();
  const { idusuarios } = req.user; // ID del usuario autenticado

  try {
      const products = await pool.query(
          `SELECT * 
           FROM Productos 
           WHERE usuarios_idusuarios = :idusuarios`,
          { replacements: { idusuarios } }
      );

      if (products[0].length === 0) {
          return res.status(404).json({ msg: 'No se encontraron productos creados por este usuario' });
      }

      res.status(200).json({ msg: 'Productos encontrados', products: products[0] });
  } catch (error) {
      console.error('Error al obtener productos:', error);
      res.status(500).json({ msg: 'Error al obtener productos' });
  }
};


// Actualizar Producto por ID
exports.updateProductById = async (req, res) => {
  const pool = await conexion();
  const { idusuarios } = req.user; // ID del usuario que realiza la solicitud
  const { id } = req.params; // ID del producto a actualizar
  const { nuevo_estado } = req.body;

  try {
      // Obtener producto y verificar propietario
      const [productoResult] = await pool.query(
          `SELECT usuarios_idusuarios FROM Productos WHERE idProductos = :id`,
          { replacements: { id } }
      );

      const producto = productoResult[0];
      if (!producto) {
          return res.status(404).json({ msg: 'Producto no encontrado' });
      }

      if (producto.usuarios_idusuarios !== idusuarios) {
          return res.status(403).json({ msg: 'Usuario no tiene permiso para actualizar este producto' });
      }

      // Actualizar estado del producto
      await pool.query(
          `EXEC p_InactivarProducto
              @idProductos = :id,
              @estados_idestados = :nuevo_estado`,
          {
              replacements: {
                  id,
                  nuevo_estado,
              },
          }
      );

      res.json({ msg: 'Producto actualizado correctamente' });
  } catch (error) {
      console.error('Error al actualizar producto:', error);
      res.status(500).json({ msg: 'Error al actualizar producto' });
  }
};